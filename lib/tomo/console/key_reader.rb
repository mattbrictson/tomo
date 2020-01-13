require "forwardable"
require "io/console"
require "time"

module Tomo
  class Console
    class KeyReader
      extend Forwardable

      def initialize(input=$stdin)
        @buffer = ""
        @input = input
      end

      def next
        pressed = raw { getc }
        pressed << read_chars_nonblock if pressed == "\e"
        raise Interrupt if pressed == ?\C-c

        clear if !pressed.match?(/\A\w+\z/) || seconds_since_last_press > 0.75
        buffer << pressed
      end

      private

      def_delegators :@input, :getc, :raw, :read_nonblock
      def_delegators :buffer, :clear

      attr_reader :buffer

      def seconds_since_last_press
        start = @last_press_at || 0
        @last_press_at = Time.now.to_f
        @last_press_at - start
      end

      def read_chars_nonblock
        chars = ""
        loop do
          next_char = raw { read_nonblock(1) }
          break if next_char.nil?

          chars << next_char
        end
        chars
      rescue IO::WaitReadable
        chars
      end
    end
  end
end
