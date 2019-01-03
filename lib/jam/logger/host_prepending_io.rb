module Jam
  class Logger
    class HostPrependingIO
      include Jam::Colors

      def initialize(io)
        @io = io
      end

      def puts(str)
        prefix = Framework::Current.host&.name
        return io.puts(str) if prefix.nil?

        io.puts(str.to_s.gsub(/^/, gray("[#{prefix}] ")))
      end

      private

      attr_reader :io
    end
  end
end
