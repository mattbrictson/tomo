require "optparse"

module Jam
  class CLI
    class Options
      def self.parse(argv)
        argv = argv.dup
        settings = {}
        environment = nil

        OptionParser.new do |opts|
          opts.on("-s", "--setting=NAME=VALUE") do |setting|
            name, value = setting.split("=", 2)
            settings[name.to_sym] = value
          end
          opts.on("-e", "--environment=ENVIRONMENT") do |env|
            environment = env
          end
        end.parse!(argv)

        new(environment: environment, extra_args: argv, settings: settings)
      end

      attr_reader :environment, :extra_args, :settings

      def initialize(environment: nil, extra_args: [], settings: {})
        @environment = environment
        @extra_args = extra_args
        @settings = settings
      end
    end
  end
end
