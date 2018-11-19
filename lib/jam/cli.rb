module Jam
  class CLI
    autoload :DeployOptions, "jam/cli/deploy_options"
    autoload :Parser, "jam/cli/parser"

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
    end
  end
end
