module Tomo
  class CLI
    class Error < ::Tomo::Error
      attr_accessor :command_name

      def to_console
        <<~ERROR
          #{message}

          Run #{blue("tomo #{command_name} -h")} for help.
        ERROR
      end
    end
  end
end
