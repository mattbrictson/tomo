require "forwardable"

module Jam
  class Logger
    autoload :HostPrependingIO, "jam/logger/host_prepending_io"

    extend Forwardable
    include Jam::Colors

    def initialize(stdout: $stdout, stderr: $stderr)
      @stdout = HostPrependingIO.new(stdout)
      @stderr = HostPrependingIO.new(stderr)
    end

    def prefix_host(host, prefix)
      @stdout.prefix_host(host, prefix)
      @stderr.prefix_host(host, prefix)
    end

    def script_start(script)
      return unless script.echo?

      puts yellow(script.echo_string)
    end

    def script_output(script, output)
      return if script.silent?

      puts output
    end

    def script_end(script, result)
      return unless result.failure?
      return unless script.silent?
      return unless script.raise_on_error?

      puts result.output
    end

    def connect(host)
      puts gray("→ Connecting to #{host}")
    end

    def task_start(task)
      puts blue("• #{task}")
    end

    def info(message)
      puts message
    end

    def error(message)
      stderr.puts indent("\n" + red("ERROR: ") + message.strip + "\n\n")
    end

    def debug(message)
      return unless Jam.debug?

      stderr.puts gray("DEBUG: #{message}")
    end

    private

    def_delegators :@stdout, :puts
    attr_reader :stderr

    def indent(message, prefix="  ")
      message.gsub(/^/, prefix)
    end
  end
end
