require "forwardable"

module Tomo
  class CLI
    module Command
      extend Forwardable

      def_delegators :@parser, :arg, :option, :after_parse
      attr_reader :parser

      def self.extended(mod)
        mod.include Colors
        mod.instance_variable_set(:@parser, Parser.new)
      end

      def parse(argv)
        command = new
        @parser.context = command
        @parser.banner = command.method(:banner)
        *args, options = @parser.parse(argv)
        command.call(*args, options)
      end
    end
  end
end
