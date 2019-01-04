module Tomo
  module SSH
    class Error < Tomo::Error
      attr_accessor :host

      def to_console
        [debug_suggestion, red(message.strip)].compact.join("\n\n")
      end
    end
  end
end
