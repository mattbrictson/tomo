require "fileutils"
require "securerandom"
require "tmpdir"

# TODO: register at_exit to call #close

module Jam
  module SSH
    class Connection
      attr_reader :host

      def initialize(host, options)
        @host = host
        @options = options
      end

      def ssh_exec(script)
        ssh_args = build_args(script)
        logger.script_start(script)
        Jam.logger.debug ssh_args.map(&:shellescape).join(" ")
        Process.exec(*ssh_args)
      end

      def ssh_subprocess(script, verbose: false)
        ssh_args = build_args(script, verbose)
        handle_data = ->(data) { logger.script_output(script, data) }

        logger.script_start(script)
        result = ChildProcess.execute(*ssh_args, on_data: handle_data)
        logger.script_end(script, result)

        if result.failure? && script.raise_on_error?
          raise_run_error(script, ssh_args, result)
        end

        result
      end

      def close
        FileUtils.rm_f(control_path)
      end

      private

      attr_reader :options

      def logger
        Jam.logger
      end

      def build_args(script, verbose=false)
        options.build_args(host, script, control_path, verbose)
      end

      def control_path
        @control_path ||= begin
          token = SecureRandom.hex(8)
          File.join(Dir.tmpdir, "jam_ssh_#{token}")
        end
      end

      def raise_run_error(script, ssh_args, result)
        ScriptError.raise_with(
          result.output,
          host: host,
          result: result,
          script: script,
          ssh_args: ssh_args
        )
      end
    end
  end
end
