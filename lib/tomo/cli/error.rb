module Tomo
  class CLI
    class Error < ::Tomo::Error
      attr_accessor :command_name

      def to_console
        tomo_command = ["tomo", command_name].compact.join(" ")
        <<~ERROR
          #{message}

          Run #{blue("#{tomo_command} -h")} for help.
        ERROR
      end
    end
  end
end
