module Jam
  class CLI
    autoload :DeployOptions, "jam/cli/deploy_options"
    autoload :Parser, "jam/cli/parser"

    COMMANDS = {
      "deploy" => Jam::Commands::Deploy,
      "run" => Jam::Commands::Run
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
