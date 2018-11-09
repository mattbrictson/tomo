require "forwardable"

module Jam
  class Logger
    extend Forwardable
    include Jam::Colors

    def initialize(stdout=$stdout)
      @stdout = stdout
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

      puts [result.stdout, result.stderr].compact.join
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
      puts indent(message, red("ERROR: "))
    end

    private

    def_delegators :@stdout, :puts

    def indent(str, leader)
      str.to_s.gsub(/\A/, leader)
         .gsub(/(?<!\A)^/, " " * leader.length)
    end
  end
end
