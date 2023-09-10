module Tomo
  module Commands
    class Default < CLI::Command
      arg "COMMAND", values: CLI::COMMANDS.keys

      option :version, "-v, --version", "Display tomo’s version and exit" do
        Version.parse([])
        CLI.exit
      end

      include CLI::CommonOptions

      def banner
        <<~BANNER
          Usage: #{green('tomo')} #{yellow('COMMAND [options]')}

          Tomo is an extensible tool for deploying projects to remote hosts via SSH.
          Please specify a #{yellow('COMMAND')}, which can be:

          #{commands.map { |name, help| "  #{yellow(name.ljust(10))} #{help}" }.join("\n")}

          The tomo CLI also provides some convenient shortcuts:

          - Commands can be abbreviated, like #{blue('tomo d')} to run #{blue('tomo deploy')}.
          - When running tasks, the #{yellow('run')} command is implied and can be omitted.
            E.g., #{blue('tomo run rails:console')} can be shortened to #{blue('tomo rails:console')}.
          - Bash completions are also available. Run #{blue('tomo completion-script')} for
            installation instructions.

          For help with any command, add #{blue('-h')} to the command, like this:

            #{blue('tomo run -h')}

          Or read the full documentation for all commands at:

            #{blue('https://tomo.mattbrictson.com/')}
        BANNER
      end

      def call(*args, options)
        # The bare `tomo` command (i.e. without `--help` or `--version`) doesn't
        # do anything, so if we got this far, something has gone wrong.

        if options.any?
          raise CLI::Error, "Options must be specified after the command: " + yellow("tomo #{args.first} [options]")
        end

        raise_unrecognized_command(args.first)
      end

      private

      def raise_unrecognized_command(command)
        error = "#{yellow(command)} is not a recognized tomo command."
        if command.match?(/\A\S+:/)
          suggestion = "tomo run #{command}"
          error << "\nMaybe you meant #{blue(suggestion)}?"
        end

        raise CLI::Error, error
      end

      def commands
        CLI::COMMANDS.each_with_object({}) do |(name, klass), result|
          command = klass.new
          help = command.summary if command.respond_to?(:summary)
          next if help.nil?

          result[name] = help
        end
      end
    end
  end
end
