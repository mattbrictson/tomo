require "open3"

module Jam
  module SSH
    class ChildProcess
      def self.execute(command, stdout_io: $stdout, stderr_io: $stderr)
        process = new(command, stdout_io: stdout_io, stderr_io: stderr_io)
        process.wait_for_exit
        process.result
      end

      def initialize(command, stdout_io:, stderr_io:)
        @command = command
        @stdout_io = stdout_io
        @stderr_io = stderr_io
        @stdout_buffer = StringIO.new
        @stderr_buffer = StringIO.new
      end

      def wait_for_exit
        Open3.popen3(command) do |stdin, stdout, stderr, wait_thread|
          stdin.close
          stdout_thread = start_io_thread(stdout, stdout_io, stdout_buffer)
          stderr_thread = start_io_thread(stderr, stderr_io, stderr_buffer)
          stdout_thread.join
          stderr_thread.join
          @exit_status = wait_thread.value.to_i
        end
      end

      def result
        Result.new(
          exit_status: exit_status,
          stdout: stdout_buffer.string,
          stderr: stderr_buffer.string
        )
      end

      private

      attr_reader :command, :exit_status
      attr_reader :stdout_io, :stderr_io, :stdout_buffer, :stderr_buffer

      def start_io_thread(source, dest_io, dest_buffer)
        Thread.new do
          while (line = source.gets)
            dest_io << line unless dest_io.nil?
            dest_buffer << line
          end
        end
      end
    end
  end
end
