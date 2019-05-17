module Tomo
  class Configuration
    class PluginFileNotFoundError < Error
      attr_accessor :path

      def to_console
        <<~ERROR
          A plugin specified by this project could not be loaded.
          File does not exist: #{yellow(path)}
        ERROR
      end
    end
  end
end
