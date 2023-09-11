module Tomo
  module Commands
    class Deploy < CLI::Command
      include CLI::DeployOptions
      include CLI::ProjectOptions
      include CLI::CommonOptions

      def summary
        "Deploy the current project to remote host(s)"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo deploy')} #{yellow('[--dry-run] [options]')}

          Sequentially run the "deploy" list of tasks specified in #{DEFAULT_CONFIG_PATH} to
          deploy the project to a remote host. Use the #{blue('--dry-run')} option to quickly
          simulate the entire deploy without actually connecting to the host. Add the
          #{blue('--debug')} option to see an in-depth explanation of the settings and execution
          plan that will be used for the deployment.

          For a #{DEFAULT_CONFIG_PATH} that specifies distinct environments (e.g. staging,
          production), you must specify the target environment using the #{blue('-e')} option. If
          you omit this option, tomo will automatically prompt for it.

          Tomo will use the settings specified in #{DEFAULT_CONFIG_PATH} to configure the
          deploy. You may override these on the command line using #{blue('-s')}. E.g.:

            #{blue('tomo deploy -e staging -s git_branch=develop')}

          Or use environment variables with the special #{blue('TOMO_')} prefix:

            #{blue('TOMO_GIT_BRANCH=develop tomo deploy -e staging')}

          Bash completions are provided for tomo’s options. For example, you could type
          #{blue('tomo deploy -s <TAB>')} to see a list of all settings, or #{blue('tomo deploy -e pr<TAB>')}
          to expand #{blue('pr')} to #{blue('production')}. For bash completion installation instructions,
          run #{blue('tomo completion-script')}.

          More documentation and examples can be found here:

            #{blue('https://tomo.mattbrictson.com/commands/deploy')}
        BANNER
      end

      def call(options)
        logger.info "tomo deploy v#{Tomo::VERSION}"

        runtime = configure_runtime(options)
        plan = runtime.deploy!

        log_completion(plan)
      end

      private

      def log_completion(plan)
        app = plan.settings[:application]
        target = "#{app} to #{plan.applicable_hosts_sentence}"

        if dry_run?
          logger.info(green("* Simulated deploy of #{target} (dry run)"))
        else
          logger.info(green("✔ Deployed #{target}"))
        end
      end
    end
  end
end
