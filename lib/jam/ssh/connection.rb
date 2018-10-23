require "fileutils"
require "securerandom"
require "shellwords"
require "tmpdir"

module Jam
  module SSH
    class Connection
      attr_reader :host

      def initialize(host)
        @host = host
      end

      def attach(command)
        ssh_command = build_ssh_command(command, pty: true)
        Process.exec(ssh_command)
      end

      def run(command, silent: false, pty: false, raise_on_error: true)
        ssh_command = build_ssh_command(command, pty: pty)
        result = ChildProcess.execute(
          ssh_command,
          stdout_io: silent ? nil : $stdout,
          stderr_io: silent ? nil : $stderr
        )
        if result.error? && raise_on_error
          raise_run_error(command, ssh_command, result)
        end

        result
      end

      def close
        FileUtils.rm_f(control_path)
      end

      private

      def build_ssh_command(command, pty:)
        unless command.is_a?(String) || command.is_a?(Symbol)
          raise ArgumentError, "command must be a string, not #{command.class}"
        end

        args = [*ssh_options]
        args << "-tt" if pty
        args << host.shellescape
        args << "--"
        args << command.to_s.shellescape

        ["ssh", *args].join(" ")
      end

      def ssh_options
        [
          "-o ControlMaster=auto",
          "-o ControlPath=#{control_path.shellescape}",
          "-o ControlPersist=30s",
          "-o LogLevel=ERROR"
        ]
      end

      def control_path
        @control_path ||= begin
          token = SecureRandom.hex(8)
          File.join(Dir.tmpdir, "jam_ssh_#{token}")
        end
      end

      def raise_run_error(remote_command, ssh_command, result)
        RemoteExecutionError.raise_with(
          "Failed with status #{result.exit_status}: #{ssh_command}",
          host: host,
          remote_command: remote_command,
          ssh_command: ssh_command,
          result: result
        )
      end
    end
  end
end
