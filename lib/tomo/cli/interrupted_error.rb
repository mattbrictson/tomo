module Tomo
  class CLI
    class InterruptedError < Error
      def to_console
        "Interrupted"
      end
    end
  end
end
