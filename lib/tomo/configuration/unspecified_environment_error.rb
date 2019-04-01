module Tomo
  class Configuration
    class UnspecifiedEnvironmentError < Tomo::Error
      attr_accessor :environments

      def to_console
        <<~ERROR
          No environment specified.

          This is a multi-environment project. To run a remote task you must specify
          which environment to use by including the #{blue('-e')} option.

          Run tomo again with one of these options to specify the environment:

          #{env_options}
        ERROR
      end

      private

      def env_options
        environments.each_with_object([]) do |env, options|
          options << blue("  -e #{env}")
        end.join("\n")
      end
    end
  end
end
