require "open3"

module Jam
  class Framework
    class ChildProcess
      def self.execute(*command, io: $stdout)
        process = new(*command, io: io)
        process.wait_for_exit
        process.result
      end

      def initialize(*command, io:)
        @command = *command
        @io = io
        @stdout_buffer = StringIO.new
        @stderr_buffer = StringIO.new
      end

      def wait_for_exit
        Open3.popen3(*command) do |stdin, stdout, stderr, wait_thread|
          stdin.close
          stdout_thread = start_io_thread(stdout, stdout_buffer)
          stderr_thread = start_io_thread(stderr, stderr_buffer)
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

      attr_reader :command, :exit_status, :io, :stdout_buffer, :stderr_buffer

      def start_io_thread(source, buffer)
        Thread.new do
          while (line = source.gets)
            io << line unless io.nil?
            buffer << line
          end
        end
      end
    end
  end
end
