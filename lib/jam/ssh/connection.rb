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

      def run(command, silent: false, pty: false)
        ssh_command = build_ssh_command(command, pty: pty)
        ChildProcess.execute(
          ssh_command,
          stdout_io: silent ? nil : $stdout,
          stderr_io: silent ? nil : $stderr,
        )
      end

      def close
        FileUtils.rm_f(control_path)
      end

      private

      attr_reader :host

      def build_ssh_command(command, pty:)
        args = [*ssh_options]
        args << "-tt" if pty
        args << host.shellescape
        args << "--"
        args << command.shellescape

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
    end
  end
end
