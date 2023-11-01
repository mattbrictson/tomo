require "shellwords"

module Tomo::Plugin::Core
  module Helpers
    def capture(*command, **run_opts)
      result = run(*command, silent: true, **run_opts)
      result.stdout
    end

    def run?(*command, **run_opts)
      result = run(*command, **run_opts.merge(raise_on_error: false))
      result.success?
    end

    def write(to:, text: nil, template: nil, append: false, **run_opts)
      assert_text_or_template_required!(text, template)
      text = merge_template(template) unless template.nil?
      message = "Writing #{text.bytesize} bytes to #{to}"
      run(
        "echo -n #{text.shellescape} #{append ? '>>' : '>'} #{to.shellescape}",
        echo: message,
        **run_opts
      )
    end

    def ln_sf(target, link, **run_opts)
      run("ln", "-sf", target, link, **run_opts)
    end

    def ln_sfn(target, link, **run_opts)
      run("ln", "-sfn", target, link, **run_opts)
    end

    def mkdir_p(*directories, **run_opts)
      run("mkdir", "-p", *directories, **run_opts)
    end

    def rm_rf(*paths, **run_opts)
      run("rm", "-rf", *paths, **run_opts)
    end

    def list_files(directory=nil, **run_opts)
      capture("ls", "-A1", directory, **run_opts).strip.split("\n")
    end

    def command_available?(command_name, **run_opts)
      run?("which", command_name, silent: true, **run_opts)
    end

    def file?(file, **run_opts)
      flag?("-f", file, **run_opts)
    end

    def executable?(file, **run_opts)
      flag?("-x", file, **run_opts)
    end

    def directory?(directory, **run_opts)
      flag?("-d", directory, **run_opts)
    end

    private

    def flag?(flag, path, **run_opts)
      run?("[ #{flag} #{path.to_s.shellescape} ]", **run_opts)
    end

    def assert_text_or_template_required!(text, template)
      return if text.nil? ^ template.nil?

      raise ArgumentError, "specify text: or template:"
    end
  end
end
