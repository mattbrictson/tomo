require "forwardable"

module Tomo
  class CLI
    class Command
      class << self
        extend Forwardable
        def_delegators :parser, :arg, :option, :after_parse

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
