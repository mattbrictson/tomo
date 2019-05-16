require "forwardable"

module Tomo
  class Logger
    autoload :TaggedIO, "tomo/logger/tagged_io"

    extend Forwardable
    include Tomo::Colors

    def initialize(stdout: $stdout, stderr: $stderr)
      @stdout = TaggedIO.new(stdout)
      @stderr = TaggedIO.new(stderr)
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

    def warn(message)
      stderr.puts red("WARNING: ") + message
    end

    def debug(message)
      return unless Tomo.debug?

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
