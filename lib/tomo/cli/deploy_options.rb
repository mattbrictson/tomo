module Tomo
  class CLI
    module DeployOptions
      def self.included(mod) # rubocop:disable Metrics/MethodLength
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

      private

      def environment_names(*_args, options)
        load_configuration(options).environments.keys
      end

      def setting_completions(*_args, options)
        runtime = configure_runtime(options, strict: false)
        settings = runtime.execution_plan_for([]).settings

        settings = settings.select do |_key, value|
          value.nil? || value.is_a?(String) || value.is_a?(Numeric)
        end.to_h

        settings.keys.map { |sett| "#{sett}=" }
      end

      def prompt_for_environment(*args, options)
        return unless options[:environment].nil?

        envs = environment_names(*args, options)
        return if envs.empty?
        return unless Console.interactive?

        options[:environment] = Console.menu("Choose an environment:", choices: envs)
      end
    end
  end
end
