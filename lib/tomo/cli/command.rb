module Tomo
  class CLI
    class Command
      class << self
        def arg(spec, values: [])
          parser.arg(spec, values: values)
        end

        def option(key, spec, desc=nil, values: [], &block)
          parser.option(key, spec, desc, values: values, &block)
        end

        def after_parse(context_method_name)
          parser.after_parse(context_method_name)
        end

        def parser
          @parser ||= Parser.new
        end

        def parse(argv)
          command = new
          parser.context = command
          parser.banner = command.method(:banner)
          *args, options = parser.parse(argv)
          command.call(*args, options)
        end
      end

      include Colors

      private

      def dry_run?
        Tomo.dry_run?
      end

      def logger
        Tomo.logger
      end
    end
  end
end
