module Jam
  module SSH
    class Error < Jam::Error
      attr_accessor :host

      def to_console
        [debug_suggestion, red(message.strip)].compact.join("\n\n")
      end
    end
  end
end
