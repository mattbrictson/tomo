require "securerandom"

module Tomo
  module Testing
    class CLITester
      include Local
      include LogCapturing

      def initialize
        @token = SecureRandom.hex(8)
      end

      def in_temp_dir(&block)
        super(token, &block)
      end

      def run(*args, raise_on_error: true)
        in_temp_dir do
          restoring_defaults do
            capturing_logger_output do
              handling_exit(raise_on_error) do
                CLI.new.call(args.flatten)
              end
            end
          end
        end
      end

      private

      attr_reader :token

      def restoring_defaults
        yield
      ensure
        Tomo.debug = false
        Tomo.dry_run = false
        Tomo::CLI.show_backtrace = false
        Tomo::CLI::Completions.instance_variable_set(:@active, false)
      end

      def handling_exit(raise_on_error)
        yield
      rescue Tomo::Testing::MockedExitError => e
        raise if raise_on_error && !e.success?
      end
    end
  end
end
