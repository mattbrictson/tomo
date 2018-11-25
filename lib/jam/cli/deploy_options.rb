module Jam
  class CLI
    module DeployOptions
      # rubocop:disable Metrics/MethodLength
      def self.call(opts, results)
        results[:settings] = {}

        opts.on("-s",
                "--setting=NAME=VALUE",
                "Override setting NAME with the given VALUE") do |setting|
          name, value = setting.split("=", 2)
          results[:settings][name.to_sym] = value
        end

        opts.on("-e",
                "--environment=ENVIRONMENT",
                "Specify environment to use (e.g. production)") do |env|
          results[:environment] = env
        end

        opts.on("--[no-]debug-ssh", "Enable/disable SSH debugging") do |debug|
          SSH.debug = debug
        end

        opts.on("--[no-]color", "Enable/disable color output") do |color|
          color ? Jam::Colors.enable : Jam::Colors.disable
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
