require "abbrev"

module Tomo
  class CLI
    autoload :Command, "tomo/cli/command"
    autoload :CommonOptions, "tomo/cli/common_options"
    autoload :Completions, "tomo/cli/completions"
    autoload :DeployOptions, "tomo/cli/deploy_options"
    autoload :Error, "tomo/cli/error"
    autoload :InterruptedError, "tomo/cli/interrupted_error"
    autoload :Options, "tomo/cli/options"
    autoload :Parser, "tomo/cli/parser"
    autoload :ProjectOptions, "tomo/cli/project_options"
    autoload :Rules, "tomo/cli/rules"
    autoload :RulesEvaluator, "tomo/cli/rules_evaluator"
    autoload :State, "tomo/cli/state"
    autoload :UnknownOptionError, "tomo/cli/unknown_option_error"
    autoload :Usage, "tomo/cli/usage"

    class << self
      attr_accessor :show_backtrace
    end

    COMMANDS = {
      "deploy" => Tomo::Commands::Deploy,
      "help" => Tomo::Commands::Help,
      "init" => Tomo::Commands::Init,
      "run" => Tomo::Commands::Run,
      "setup" => Tomo::Commands::Setup,
      "tasks" => Tomo::Commands::Tasks,
      "version" => Tomo::Commands::Version,
      "completion-script" => Tomo::Commands::CompletionScript
    }.freeze

    def call(argv)
      prepare_completions(argv)
      command, command_name = lookup_command(argv)
      command.parse(argv)
    rescue Interrupt
      handle_error(InterruptedError.new, command_name)
    rescue StandardError => e
      handle_error(e, command_name)
    end

    private

    def prepare_completions(argv)
      return unless %w[--complete --complete-word].include?(argv[0])

      Completions.activate
      argv << "" if argv.shift == "--complete"
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def lookup_command(argv)
      command_name = argv.first unless Completions.active? && argv.length == 1
      command_name = Abbrev.abbrev(COMMANDS.keys)[command_name]
      argv.shift if command_name

      # command_name = "run" if command_name.nil? && task_format?(argv.first)
      command = COMMANDS[command_name] || Tomo::Commands::Default
      [command, command_name]
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def task_format?(arg)
      arg.to_s.match?(/\A\S+:\S*\z/)
    end

    def handle_error(error, command_name)
      return if Completions.active?
      raise error unless error.respond_to?(:to_console)

      error.command_name = command_name if error.respond_to?(:command_name=)
      Tomo.logger.error(error.to_console)
      status = error.respond_to?(:exit_status) ? error.exit_status : 1
      exit(status) unless Tomo::CLI.show_backtrace

      raise error
    end
  end
end
