require "forwardable"
require "optparse"

module Tomo
  class CLI
    class Parser
      extend Forwardable

      def_delegators :opt_parse, :accept

      attr_accessor :permit_empty_args, :permit_extra_args
      attr_writer :banner, :usage

      # rubocop:disable Metrics/MethodLength
      def initialize
        @permit_empty_args = false
        @permit_extra_args = false
        @usage = nil
        @opt_parse = OptionParser.new
        @opt_parse.banner = ""
        @opt_parse.summary_indent = "  "
        @results = {}
        add_debug_option
        add_trace_option
        add_help_option
        yield(self) if block_given?
      end
      # rubocop:enable Metrics/MethodLength

      def parse(args)
        raise "Parser#parse has already been used" if results.frozen?

        args = args.dup
        opt_parse.parse!(args)
        dump_runtime_info if Tomo.debug?
        validate_remaining_args!(args)

        results[:extra_args] = args
        results.freeze
      rescue OptionParser::InvalidOption => e
        raise UnknownOptionError, e.message
      end

      def on(*args)
        opt_parse.on(*args) do |data|
          yield(data, results)
        end
      end

      def on_tail(*args)
        opt_parse.on_tail(*args) do |data|
          yield(data, results)
        end
      end

      def add(parser_extensions)
        parser_extensions.call(self, results)
      end

      def usage_and_exit!(status=0)
        puts
        puts indent(banner)
        puts
        puts indent(usage || "Options:\n#{opt_parse}")
        puts
        exit(status)
      end

      private

      attr_reader :banner, :opt_parse, :results, :usage

      def dump_runtime_info
        Tomo.logger.debug("tomo #{Tomo::VERSION}")
        Tomo.logger.debug(RUBY_DESCRIPTION)
        Tomo.logger.debug("rubygems #{Gem::VERSION}")
        Tomo.logger.debug("bundler #{Bundler::VERSION}") if Tomo.bundled?

        begin
          require "concurrent"
          Tomo.logger.debug("concurrent-ruby #{Concurrent::VERSION}")
        rescue LoadError # rubocop:disable Lint/HandleExceptions
        end
      end

      def add_debug_option
        on_tail("--[no-]debug",
                "Enable/disable verbose debug logging") do |debug|
          Tomo.debug = debug
        end
      end

      def add_trace_option
        on_tail("--[no-]trace", "Display full backtrace on error") do |trace|
          CLI.show_backtrace = trace
        end
      end

      def add_help_option
        on_tail("-h", "--help", "Print this documentation") do
          usage_and_exit!
        end
      end

      def validate_remaining_args!(args)
        usage_and_exit!(1) if args.any? && !permit_extra_args
        usage_and_exit!(1) if args.empty? && !permit_empty_args
      end

      def indent(str)
        str.gsub(/^/, "  ")
      end
    end
  end
end
