module Jam
  class CLI
    module DeployOptions
      def self.call(opts, results)
        results[:settings] = {}

        opts.on("-s", "--setting=NAME=VALUE", "Override setting NAME with the given VALUE") do |setting|
          name, value = setting.split("=", 2)
          results[:settings][name.to_sym] = value
        end

        opts.on("-e", "--environment=ENVIRONMENT", "Specify environment to use (e.g. production)") do |env|
          results[:environment] = env
        end

        opts.on("--[no-]color", "Enable/disable color output") do |color|
          color ? Jam::Colors.enable : Jam::Colors.disable
        end
      end
    end
  end
end
