module Jam
  class CLI
    autoload :Options, "jam/cli/options"

    COMMANDS = {
      "deploy" => Jam::Commands::Deploy,
      "run" => Jam::Commands::Run
    }.freeze
    private_constant :COMMANDS

    def call(argv)
      command = COMMANDS[argv.shift]
      options = Options.parse(argv)
      command.new.call(options)
    end
  end
end
