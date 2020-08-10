module Tomo
  class CLI
    module CommonOptions
      def self.included(mod) # rubocop:disable Metrics/MethodLength
        mod.class_eval do
          option :color, "--[no-]color", "Enable/disable color output" do |color|
            Colors.enabled = color
          end
          option :debug, "--[no-]debug", "Enable/disable verbose debug logging" do |debug|
            Tomo.debug = debug
          end
          option :trace, "--[no-]trace", "Display full backtrace on error" do |trace|
            CLI.show_backtrace = trace
          end
          option :help, "-h, --help", "Print this documentation" do |_help|
            puts instance_variable_get(:@parser)
            CLI.exit
          end

          after_parse :dump_runtime_info
        end
      end

      private

      def dump_runtime_info(*)
        Tomo.logger.debug("tomo #{Tomo::VERSION}")
        Tomo.logger.debug(RUBY_DESCRIPTION)
        Tomo.logger.debug("rubygems #{Gem::VERSION}")
        Tomo.logger.debug("bundler #{Bundler::VERSION}") if Tomo.bundled?

        begin
          require "concurrent"
          Tomo.logger.debug("concurrent-ruby #{Concurrent::VERSION}")
        rescue LoadError # rubocop:disable Lint/SuppressedException
        end
      end
    end
  end
end
