module Tomo
  class Configuration
    class ProjectNotFoundError < Tomo::Error
      attr_accessor :path

      def to_console
        path == DEFAULT_CONFIG_PATH ? default_message : custom_message
      end

      private

      def default_message
        <<~ERROR
          A #{yellow(path)} configuration file is required to run this command.
          Are you in the right directory?

          To create a new #{yellow(path)} file, run #{blue('tomo init')}.
        ERROR
      end

      def custom_message
        <<~ERROR
          #{yellow(path)} does not exist.
        ERROR
      end
    end
  end
end
