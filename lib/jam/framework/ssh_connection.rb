require "fileutils"
require "securerandom"
require "tmpdir"

module Jam
  class Framework
    class SSHConnection
      attr_reader :host

      def initialize(host:,
                     logger:,
                     forward_agent: true,
                     reuse_connections: true,
                     extra_opts: {})
        @host = host
        @logger = logger
        @forward_agent = forward_agent
        @reuse_connections = reuse_connections
        @extra_opts = extra_opts
        validate!
      end

      def ssh_exec(script)
        ssh_args = build_ssh_args(script)
        logger.script_start(script)
        Process.exec(*ssh_args)
      end

      def ssh_subprocess(script)
        ssh_args = build_ssh_args(script)
        handle_data = ->(data) { logger.script_output(script, data) }

        logger.script_start(script)
        result = ChildProcess.execute(*ssh_args, on_data: handle_data)
        logger.script_end(script, result)

        if result.failure? && script.raise_on_error?
          raise_run_error(script, ssh_args.join(" "), result)
        end

        result
      end

      def close
        FileUtils.rm_f(control_path)
      end

      private

      attr_reader :logger, :forward_agent, :reuse_connections, :extra_opts

      def validate!
        logger.connect(host)
        result = ssh_subprocess(
          Script.new("echo hi", silent: true, echo: false)
        )
        raise unless result.stdout.chomp == "hi"
      rescue StandardError
        raise "Unable to connect to #{host}"
      end

      def build_ssh_args(script)
        args = [*ssh_options]
        args << "-tt" if script.pty?
        args << host.split
        args << "--"

        ["ssh", args, script.to_s].flatten
      end

      def ssh_options
        opts = ["-o LogLevel=ERROR"]
        opts << "-A" if forward_agent
        opts.push(*control_path_opts) if reuse_connections
        opts.push(*extra_opts) if extra_opts
        opts
      end

      def control_path_opts
        [
          "-o ControlMaster=auto",
          "-o ControlPath=#{control_path}",
          "-o ControlPersist=30s"
        ]
      end

      def control_path
        @control_path ||= begin
          token = SecureRandom.hex(8)
          File.join(Dir.tmpdir, "jam_ssh_#{token}")
        end
      end

      def raise_run_error(script, ssh_command, result)
        RemoteExecutionError.raise_with(
          "Failed with status #{result.exit_status}: #{ssh_command}",
          host: host,
          script: script,
          ssh_command: ssh_command,
          result: result
        )
      end
    end
  end
end
