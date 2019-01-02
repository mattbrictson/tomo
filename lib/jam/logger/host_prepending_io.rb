module Jam
  class Logger
    class HostPrependingIO
      include Jam::Colors

      def initialize(io)
        @io = io
      end

      def puts(str)
        return if str.nil?

        prefix = Framework::Current.host&.name
        return io.puts(str) if prefix.nil?

        io.puts(str.gsub(/^/, gray("[#{prefix}] ")))
      end

      private

      attr_reader :io
    end
  end
end
