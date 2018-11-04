require "forwardable"

module Jam
  class Logger
    extend Forwardable
    include Jam::Colors

    def initialize(stdout=$stdout)
      @stdout = stdout
    end

    def command_start(command)
      return unless command.echo?

      puts yellow(command.echo_string)
    end

    def command_output(command, output)
      return if command.silent?

      puts output
    end

    def command_end(command, result)
      return unless result.failure?
      return unless command.silent?
      return unless command.raise_on_error?

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
