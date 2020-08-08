require "fileutils"
require "securerandom"
require "tmpdir"

module Tomo
  module SSH
    class Connection
      def self.dry_run(host, options)
        new(host, options, exec_proc: proc { CLI.exit }, child_proc: proc { Result.empty_success })
      end

      attr_reader :host

      def initialize(host, options, exec_proc: nil, child_proc: nil)
        @host = host
        @options = options
        @exec_proc = exec_proc || Process.method(:exec)
        @child_proc = child_proc || ChildProcess.method(:execute)
      end

      def ssh_exec(script)
        ssh_args = build_args(script)
        logger.script_start(script)
        Tomo.logger.debug ssh_args.map(&:shellescape).join(" ")
        exec_proc.call(*ssh_args)
      end

      def ssh_subprocess(script, verbose: false)
        ssh_args = build_args(script, verbose: verbose)
        handle_data = ->(data) { logger.script_output(script, data) }

        logger.script_start(script)
        result = child_proc.call(*ssh_args, on_data: handle_data)
        logger.script_end(script, result)

        raise_run_error(script, ssh_args, result) if result.failure? && script.raise_on_error?

        result
      end

      def close
        FileUtils.rm_f(control_path)
      end

      private

      attr_reader :options, :exec_proc, :child_proc

      def logger
        Tomo.logger
      end

      def build_args(script, verbose: false)
        options.build_args(host, script, control_path, verbose)
      end

      def control_path
        @control_path ||= begin
          token = SecureRandom.hex(8)
          File.join(Dir.tmpdir, "tomo_ssh_#{token}")
        end
      end

      def raise_run_error(script, ssh_args, result)
        ScriptError.raise_with(result.output, host: host, result: result, script: script, ssh_args: ssh_args)
      end
    end
  end
end
