module Tomo
  class Logger
    class TaggedIO
      include Colors

      def initialize(io)
        @io = io
      end

      def puts(str)
        io.puts(str.to_s.gsub(/^/, prefix))
      end

      private

      attr_reader :io

      def prefix
        host = Runtime::Current.host
        return "" if host.nil?

        tags = []
        tags << red("*") if Tomo.dry_run?
        unless host.log_prefix.nil?
          tags << gray("[") + host.log_prefix + gray("]")
        end
        return "" if tags.empty?

        "#{tags.join(' ')} "
      end
    end
  end
end
