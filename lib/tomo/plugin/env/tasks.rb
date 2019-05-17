require "monitor"

module Tomo::Plugin::Env
  class Tasks < Tomo::TaskLibrary
    include MonitorMixin

    def show
      env = read_existing
      logger.info env.gsub(/^export /, "").strip
    end

    def setup
      update
      modify_bashrc
    end

    def update
      return if settings[:env_vars].empty?

      modify_env_file do |env|
        settings[:env_vars].each do |name, value|
          next if value == :prompt && contains_entry?(env, name)

          value = prompt_for(name) if value == :prompt
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
    end

    def read_existing
      remote.capture(
        "cat", paths.env,
        raise_on_error: false, echo: false, silent: true
      )
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
      text.prepend("export #{name.to_s.shellescape}=#{value.shellescape}")
    end

    def contains_entry?(text, name)
      return true if dry_run?

      text.match?(/^export #{Regexp.quote(name.to_s.shellescape)}=/)
    end

    def prompt_for(name)
      synchronize do
        @answers ||= {}
        next @answers[name] if @answers.key?(name)

        @answers[name] = Tomo::Console.prompt("#{name}? ")
      end
    end

    def modify_bashrc
      env_path = paths.env.shellescape
      existing_rc = remote.capture("cat", paths.bashrc, raise_on_error: false)
      return if existing_rc.include?(". #{env_path}")

      remote.write(text: <<~BASHRC + existing_rc, to: paths.bashrc)
        if [ -f #{env_path} ]; then
          . #{env_path}
        fi

      BASHRC
    end
  end
end
