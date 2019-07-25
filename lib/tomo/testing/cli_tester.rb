require "securerandom"

module Tomo
  module Testing
    class CLITester
      include Local

      def initialize
        @token = SecureRandom.hex(8)
      end

      def run(*args, raise_on_error: true)
        in_temp_dir(token) do
          restoring_defaults do
            capturing_logger_output do
              handling_exit(raise_on_error) do
                CLI.new.call(args.flatten)
              end
            end
          end
        end
      end

      def stdout
        @stdout_io&.string
      end

      def stderr
        @stderr_io&.string
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

      # TODO: move to mixin
      def capturing_logger_output
        orig_logger = Tomo.logger
        @stdout_io = StringIO.new
        @stderr_io = StringIO.new
        Tomo.logger = Tomo::Logger.new(stdout: @stdout_io, stderr: @stderr_io)
        yield
      ensure
        Tomo.logger = orig_logger
      end

      def handling_exit(raise_on_error)
        yield
      rescue Tomo::Testing::MockedExitError => e
        raise if raise_on_error && !e.success?
      end
    end
  end
end
