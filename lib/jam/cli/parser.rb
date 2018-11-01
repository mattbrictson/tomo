require "forwardable"
require "optparse"

module Jam
  class CLI
    class Parser
      extend Forwardable

      def_delegators :opt_parse, :accept, :banner=

      def initialize
        @opt_parse = OptionParser.new
        @results = {}
        add_help_option
      end

      def parse(args, permit_extra_args: false)
        raise "Parser#parse has already been used" if results.frozen?

        args = args.dup
        opt_parse.parse!(args)
        # TODO: print a nicer error instead of just showing the usage
        usage_and_exit!(1) if args.any? && !permit_extra_args

        results[:extra_args] = args
        results.freeze
      end

      def on(*args)
        opt_parse.on(*args) do |data|
          yield(data, results)
        end
      end

      def add(parser_extensions)
        parser_extensions.call(self, results)
      end

      private

      attr_reader :opt_parse, :results

      def add_help_option
        on("-h", "--help", "Prints this documentation") do
          usage_and_exit!
        end
      end

      def usage_and_exit!(status=0)
        puts opt_parse
        exit(status)
      end
    end
  end
end
