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
        tags << grayish("[#{host.log_prefix}]") unless host.log_prefix.nil?
        return "" if tags.empty?

        "#{tags.join(' ')} "
      end

      def grayish(str)
        parts = str.split(/(\e.*?\e\[0m)/)
        parts.map! do |part|
          part.start_with?("\e") ? part : gray(part)
        end.join
      end
    end
  end
end
