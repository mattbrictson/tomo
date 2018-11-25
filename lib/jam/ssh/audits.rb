require "forwardable"

module Jam
  module SSH
    # TODO: rename to ConnectionValidator
    class Audits
      MINIMUM_OPENSSH_VERSION = 7.6
      private_constant :MINIMUM_OPENSSH_VERSION

      extend Forwardable

      def initialize(executable, connection)
        @executable = executable
        @connection = connection
      end

      def assert_valid_executable!
        result = begin
                   # TODO: move to Connection#ssh_version
                   ChildProcess.execute(executable, "-V")
                 rescue StandardError => error
                   handle_bad_executable(error)
                 end

        Jam.logger.debug(result.output) if SSH.debug?
        return if result.success? && supported?(result.output)

        raise_unsupported_version(result.output)
      end

      def assert_valid_connection!
        script = Script.new(
          "echo hi",
          silent: !SSH.debug?, echo: false, raise_on_error: false
        )
        res = connection.ssh_subprocess(script, verbose: SSH.debug?)
        raise_connection_failure(res) if res.exit_status == 255
        raise_unknown_error(res) if res.failure? || res.stdout.chomp != "hi"
      end

      private

      def_delegators :connection, :host
      attr_reader :executable, :connection

      def supported?(version)
        version[/OpenSSH_(\d+\.\d+)/i, 1].to_f >= MINIMUM_OPENSSH_VERSION
      end

      def handle_bad_executable(error)
        ExecutableError.raise_with(error, executable: executable)
      end

      def raise_unsupported_version(ver)
        UnsupportedVersionError.raise_with(
          ver,
          host: host,
          command: "#{executable} -V",
          expected_version: "OpenSSH_#{MINIMUM_OPENSSH_VERSION}"
        )
      end

      def raise_connection_failure(result)
        case result.output
        when /Permission denied/i
          PermissionError.raise_with(result.output, host: host)
        when /(Could not resolve|Operation timed out|Connection refused)/i
          ConnectionError.raise_with(result.output, host: host)
        else
          UnknownError.raise_with(result.output, host: host)
        end
      end

      def raise_unknown_error(result)
        UnknownError.raise_with(<<~ERROR.strip, host: host)
          Unexpected output from `ssh`. Expected `echo hi` to return "hi" but got:
          #{result.output}
          (exited with code #{result.exit_status})
        ERROR
      end
    end
  end
end
