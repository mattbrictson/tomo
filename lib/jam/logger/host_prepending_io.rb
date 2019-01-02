module Jam
  class Logger
    class HostPrependingIO
      include Jam::Colors

      def initialize(io)
        @io = io
        @prefixes = {}
      end

      def prefix_host(host, prefix)
        prefixes[host] = prefix
      end

      def puts(str)
        return if str.nil?

        prefix = prefixes[Framework::Current.host]
        return io.puts(str) if prefix.nil?

        io.puts(str.gsub(/^/, gray("[#{prefix}] ")))
      end

      private

      attr_reader :io, :prefixes
    end
  end
end
