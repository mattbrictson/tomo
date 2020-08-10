module Tomo
  class CLI
    module ProjectOptions
      def self.included(mod)
        mod.class_eval do
          option :project, "-c, --config PATH", "Location of project config (default: #{DEFAULT_CONFIG_PATH})"
        end
      end

      private

      def configure_runtime(options, strict: true)
        config = load_configuration(options)
        env = options[:environment]
        env = config.environments.keys.first if env.nil? && !strict
        config = config.for_environment(env)
        config.settings.merge!(settings_from_env)
        config.settings.merge!(settings_from_options(options))
        config.build_runtime
      end

      def load_configuration(options)
        path = options[:project] || DEFAULT_CONFIG_PATH
        @config_cache ||= {}
        @config_cache[path] ||= Configuration.from_config_rb(path)
      end

      def settings_from_options(options)
        options.all(:settings).each_with_object({}) do |arg, settings|
          name, value = arg.split("=", 2)
          settings[name.to_sym] = value
        end
      end

      def settings_from_env
        ENV.each_with_object({}) do |(key, value), result|
          setting_name = key[/^TOMO_(\w+)$/i, 1]&.downcase
          next if setting_name.nil?

          result[setting_name.to_sym] = value
        end
      end
    end
  end
end
