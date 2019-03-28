require "time"

module Tomo
  class CLI
    module ProjectOptions
      private

      def configure_project(options, default_environment=nil, settings: {})
        settings = settings.merge(start_time: Time.now)
        Tomo.load_project!(
          environment: options.fetch(:environment, default_environment),
          settings: settings_from_options(options).merge(settings)
        )
      end

      def settings_from_options(options)
        options.all(:settings).each_with_object({}) do |arg, settings|
          name, value = arg.split("=", 2)
          settings[name.to_sym] = value
        end
      end
    end
  end
end
