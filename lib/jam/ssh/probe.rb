require "English"

module Jam
  module SSH
    class Probe
      def self.test!(connection)
        new(connection).tap(&:call)
      end

      def initialize(connection)
        @connection = connection
      end

      def call
        assert_openssh_executable

        script = Script.new(
          "echo hi",
          silent: true, echo: false, raise_on_error: false
        )
        res = connection.ssh_subprocess(script)
        raise_connection_failure(res) if res.exit_status == 255
        raise_unknown_error(res) if res.failure? || res.stdout.chomp != "hi"
      end

      private

      attr_reader :connection

      def assert_openssh_executable
        # TODO: get executable path from connection object
        result = begin
                   Jam::Framework::ChildProcess.execute("ssh", "-V")
                 rescue StandardError => error
                   handle_bad_executable(error)
                 end

        return if result.success? && supported?(result.output)

        raise_unsupported_version(result)
      end

      def supported?(version)
        version[/OpenSSH_(\d+\.\d+)/i, 1].to_f >= 7.6
      end

      def handle_bad_executable(error)
        # TODO: raise appropriate Jam::Error type
        raise <<~ERROR.strip
          `ssh -V` failed to execute. Is ssh installed and in your $PATH?
          #{error}
        ERROR
      end

      def raise_unsupported_version(ver)
        # TODO: raise appropriate Jam::Error type
        raise "Expected `ssh -V` to be OpenSSH_7.6 or higher but got: #{ver}"
      end

      def raise_connection_failure(result)
        # TODO: raise appropriate exception type based on output:
        # * Operation timed out
        # * Could not resolve hostname
        # * Connection refused
        # * Permission denied
        raise <<~ERROR.strip
          Unable to connect to #{connection.host} via `ssh`:
          #{result.output}
        ERROR
      end

      def raise_unknown_error(result)
        # TODO: raise appropriate Jam::Error type
        raise <<~ERROR.strip
          Unexpected output from `ssh`. Expected `echo hi` to return "hi" but got:
          #{result.output}
          (exited with code #{result.exit_status})
        ERROR
      end
    end
  end
end
