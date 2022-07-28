require "open3"
require "shellwords"
require "stringio"

module Tomo
  module SSH
    class ChildProcess
      def self.execute(*command, on_data: ->(data) {})
        process = new(*command, on_data: on_data)
        process.wait_for_exit
        process.result
      end

      def initialize(*command, on_data:)
        @command = *command
        @on_data = on_data
        @stdout_buffer = StringIO.new
        @stderr_buffer = StringIO.new
        Tomo.logger.debug command.map(&:shellescape).join(" ")
      end

      def wait_for_exit
        Open3.popen3(*command) do |stdin, stdout, stderr, wait_thread|
          stdin.close
          stdout_thread = start_io_thread(stdout, stdout_buffer)
          stderr_thread = start_io_thread(stderr, stderr_buffer)
          stdout_thread.join
          stderr_thread.join
          @exit_status = wait_thread.value.exitstatus
        end
      end

      def result
        Result.new(exit_status: exit_status, stdout: stdout_buffer.string, stderr: stderr_buffer.string)
      end

      private

      attr_reader :command, :exit_status, :on_data, :stdout_buffer, :stderr_buffer

      def start_io_thread(source, buffer)
        new_thread_inheriting_current_vars do
          while (line = source.gets)
            on_data&.call(line)
            buffer << line
          end
        rescue IOError # rubocop:disable Lint/SuppressedException
        end
      end

      def new_thread_inheriting_current_vars(&block)
        Thread.new(Runtime::Current.variables) do |vars|
          Runtime::Current.with(vars, &block)
        end
      end
    end
  end
end
