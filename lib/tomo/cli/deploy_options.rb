module Tomo
  class CLI
    module DeployOptions
      # rubocop:disable Metrics/MethodLength
      def self.included(mod)
        mod.class_eval do
          option :environment,
                 "-e, --environment ENVIRONMENT",
                 "Specify environment to use (e.g. production)",
                 values: :environment_names

          option :settings,
                 "-s, --setting NAME=VALUE",
                 "Override setting NAME with the given VALUE",
                 values: :setting_completions

          option :dry_run,
                 "--[no-]dry-run",
                 "Simulate running tasks instead of using real SSH" do |dry|
            Tomo.dry_run = dry
          end

          after_parse :prompt_for_environment
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def environment_names(*_args, options)
        load_project(options).environment_names
      end

      def setting_completions(*_args, options)
        settings = configure_runtime(options, strict: false).settings
        settings.keys.map { |sett| "#{sett}=" }
      end

      def prompt_for_environment(*args, options)
        return unless options[:environment].nil?

        envs = environment_names(*args, options)
        return if envs.empty?

        options[:environment] = Menu.prompt_if_available(
          "Choose an environment:",
          envs
        )
      end
    end
  end
end
