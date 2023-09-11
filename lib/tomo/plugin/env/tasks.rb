require "monitor"

module Tomo::Plugin::Env
  class Tasks < Tomo::TaskLibrary # rubocop:disable Metrics/ClassLength
    include MonitorMixin

    def show
      env = read_existing
      logger.info env.gsub(/^export /, "").strip
    end

    def setup
      modify_bashrc
      update
    end

    def update
      return if settings[:env_vars].empty?

      modify_env_file do |env|
        settings[:env_vars].each do |name, value|
          next if value == :prompt && contains_entry?(env, name)

          value = prompt_for(name, message: <<~MSG) if value == :prompt
            The remote host needs a value for the $#{name} environment variable.
            Please provide a value at the prompt.
          MSG
          replace_entry(env, name, value)
        end
      end
    end

    def set
      return if settings[:run_args].empty?

      modify_env_file do |env|
        settings[:run_args].each do |arg|
          name, value = arg.split("=", 2)
          value ||= prompt_for(name)
          replace_entry(env, name, value)
        end
      end
    end

    def unset
      return if settings[:run_args].empty?

      modify_env_file do |env|
        settings[:run_args].each do |name|
          remove_entry(env, name)
        end
      end
    end

    private

    def modify_env_file
      env = read_existing
      original = env.dup
      yield(env)
      return if env == original

      remote.mkdir_p(paths.env.dirname) if original.empty?
      remote.write(text: env, to: paths.env)
      remote.run("chmod", "600", paths.env) if original.empty?
    end

    def read_existing
      remote.capture("cat", paths.env, raise_on_error: false, echo: false, silent: true)
    end

    def replace_entry(text, name, value)
      remove_entry(text, name)
      prepend_entry(text, name, value)
    end

    def remove_entry(text, name)
      text.gsub!(/^export #{Regexp.quote(name.to_s.shellescape)}=.*\n/, "")
    end

    def prepend_entry(text, name, value)
      text.prepend("\n") unless text.start_with?("\n")
      text.prepend("export #{name.to_s.shellescape}=#{value.to_s.shellescape}")
    end

    def contains_entry?(text, name)
      return true if dry_run?

      text.match?(/^export #{Regexp.quote(name.to_s.shellescape)}=/)
    end

    def prompt_for(name, message: nil)
      synchronize do
        @answers ||= {}
        next @answers[name] if @answers.key?(name)

        logger.info(message) if message
        @answers[name] = Tomo::Console.prompt("#{name}? ")
      end
    end

    def modify_bashrc
      env_path = paths.env.shellescape
      existing_rc = remote.capture("cat", paths.bashrc, raise_on_error: false)
      return if existing_rc.include?(". #{env_path}")

      fail_if_different_app_already_configured!(existing_rc)

      remote.write(text: <<~BASHRC + existing_rc, to: paths.bashrc)
        if [ -f #{env_path} ]; then  # DO NOT MODIFY THESE LINES
          . #{env_path}              # ENV MAINTAINED BY TOMO
        fi                #{' ' * env_path.to_s.length}# END TOMO ENV

      BASHRC
    end

    def fail_if_different_app_already_configured!(bashrc)
      existing_env_path = bashrc[/\s*\.\s+(.+)\s+# ENV MAINTAINED BY TOMO/, 1]
      return if existing_env_path.nil?

      die <<~REASON
        Based on the contents of #{paths.bashrc}, it looks like another application
        is already being deployed via tomo to this host, using the following envrc
        path:

          #{existing_env_path}

        Tomo is designed such that only one application can be deployed to a given
        user@host. To deploy multiple applications to the same host, use a separate
        deployer user per app. Refer to the tomo FAQ for details:

          https://tomo.mattbrictson.com/#faq

        You may be receiving this message in error if you recently renamed or
        reconfigured your application. In this case, remove the references to the
        old envrc path in the host's #{paths.bashrc} and re-run env:setup.
      REASON
    end
  end
end
