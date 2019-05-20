module Tomo::Plugin::Puma
  class Tasks < Tomo::TaskLibrary
    def restart
      return if try_restart

      remote.chdir(paths.current) do
        logger.info "Puma is not running. Starting it now."
        remote.bundle("exec", "puma", "--daemon", *control_options)
      end
    end

    private

    def try_restart
      ctl_result = remote.chdir(paths.current) do
        ctl_result = remote.bundle(
          "exec", "pumactl", *control_options, "restart",
          raise_on_error: false,
          silent: true
        )
      end

      return false if dry_run? || ctl_result.failure?

      logger.info(ctl_result.output)
      true
    end

    def control_options
      require_settings :puma_control_token, :puma_control_url

      [
        "--control-url", settings[:puma_control_url],
        "--control-token", settings[:puma_control_token]
      ]
    end
  end
end
