module Jam
  class CLI
    module DeployOptions
      def self.call(opts, results)
        results[:settings] = {}

        opts.on("-s", "--setting=NAME=VALUE") do |setting|
          name, value = setting.split("=", 2)
          results[:settings][name.to_sym] = value
        end

        opts.on("-e", "--environment=ENVIRONMENT") do |env|
          results[:environment] = env
        end
      end
    end
  end
end
