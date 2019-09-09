module Tomo::Plugin::Puma
  class Tasks < Tomo::TaskLibrary
    def restart
      return if try_restart

      logger.info "Puma is not running. Starting it now."
      start
    end

    private

    def try_restart
      ctl_result = remote.chdir(paths.current) do
        remote.bundle(
          "exec", "pumactl", *control_options, "restart",
          raise_on_error: false,
          silent: true
        )
      end

      return false if dry_run? || ctl_result.failure?

      logger.info(ctl_result.output)
      true
    end

    def start
      require_settings :puma_stdout_path, :puma_stderr_path

      ensure_output_directory

      remote.chdir(paths.current) do
        remote.bundle(
          "exec", "puma", "--daemon", *control_options, *output_options
        )
      end
    end

    def ensure_output_directory
      dirs = [paths.puma_stdout, paths.puma_stderr].map(&:dirname).map(&:to_s)
      remote.mkdir_p dirs.uniq
    end

    def control_options
      require_settings :puma_control_token, :puma_control_url

      [
        "--control-url", settings[:puma_control_url],
        "--control-token", settings[:puma_control_token]
      ]
    end

    def output_options
      options = []
      options << ["--redirect-stdout", paths.puma_stdout] if paths.puma_stdout
      options << ["--redirect-stderr", paths.puma_stderr] if paths.puma_stderr
      options.flatten
    end
  end
end
