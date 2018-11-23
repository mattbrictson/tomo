module Jam
  class CLI
    autoload :DeployOptions, "jam/cli/deploy_options"
    autoload :Parser, "jam/cli/parser"

    class << self
      attr_accessor :show_backtrace
    end

    COMMANDS = {
      "deploy" => Jam::Commands::Deploy,
      "init" => Jam::Commands::Init,
      "run" => Jam::Commands::Run,
      "tasks" => Jam::Commands::Tasks
    }.freeze

    def call(argv)
      command = if COMMANDS.key?(argv.first)
                  COMMANDS[argv.shift].new
                else
                  Jam::Commands::Default.new
                end

      options = command.parser.parse(argv)
      command.call(options)
    rescue StandardError => error
      handle_error(error)
    end

    private

    def handle_error(error)
      raise error unless error.respond_to?(:to_console)

      Jam.logger.error(error.to_console)
      exit(1) unless Jam::CLI.show_backtrace

      raise error
    end
  end
end
