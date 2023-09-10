module Tomo
  module Commands
    class Setup < CLI::Command
      include CLI::DeployOptions
      include CLI::ProjectOptions
      include CLI::CommonOptions

      def summary
        "Prepare the current project for its first deploy"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo setup')} #{yellow('[--dry-run] [options]')}

          Prepare the remote host for its first deploy by sequentially running the
          "setup" list of tasks specified in #{DEFAULT_CONFIG_PATH}. These tasks typically
          create directories, initialize data stores, install prerequisite tools,
          and perform other one-time actions that are necessary before a deploy can
          take place.

          Use the #{blue('--dry-run')} option to quickly simulate the setup without actually
          connecting to the host.

          More documentation and examples can be found here:

            #{blue('https://tomo.mattbrictson.com/commands/setup')}
        BANNER
      end

      def call(options)
        logger.info "tomo setup v#{Tomo::VERSION}"

        runtime = configure_runtime(options)
        plan = runtime.setup!

        log_completion(plan)
      end

      private

      def log_completion(plan)
        app = plan.settings[:application]
        target = "#{app} on #{plan.applicable_hosts_sentence}"

        if dry_run?
          logger.info(green("* Simulated setup of #{target} (dry run)"))
        else
          logger.info(green("✔ Performed setup of #{target}"))
        end
      end
    end
  end
end
