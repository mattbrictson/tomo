module Jam
  class CLI
    autoload :DeployOptions, "jam/cli/deploy_options"
    autoload :Parser, "jam/cli/parser"

    COMMANDS = {
      "deploy" => Jam::Commands::Deploy,
      "run" => Jam::Commands::Run
    }.freeze
    private_constant :COMMANDS

    def call(argv)
      command = COMMANDS[argv.shift]
      command.new.call(argv)
    end
  end
end
