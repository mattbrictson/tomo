require "stringio"

module Tomo
  module Testing
    module LogCapturing
      def stdout
        @stdout_io&.string
      end

      def stderr
        @stderr_io&.string
      end

      private

      def capturing_logger_output
        orig_logger = Tomo.logger
        @stdout_io = StringIO.new
        @stderr_io = StringIO.new
        Tomo.logger = Tomo::Logger.new(stdout: @stdout_io, stderr: @stderr_io)
        yield
      ensure
        Tomo.logger = orig_logger
      end
    end
  end
end
