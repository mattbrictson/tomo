module Tomo
  module Commands
    class Run < CLI::Command
      include CLI::DeployOptions

      option :privileged, "--[no-]privileged", "Run the task using a privileged user (e.g. root)"

      include CLI::ProjectOptions
      include CLI::CommonOptions

      arg "TASK", values: :task_names
      arg "[ARGS...]"

      def summary
        "Run a specific remote task from the current project"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo run')} #{yellow('[--dry-run] [options] [--] TASK [ARGS...]')}

          Remotely run one specified #{yellow('TASK')}, optionally passing #{yellow('ARGS')} to that task.
          For example, if this project uses the "rails" plugin, you could run:

            #{blue('tomo run -- rails:console --sandbox')}

          This will run the #{blue('rails:console')} task on the host specified in
          #{DEFAULT_CONFIG_PATH}, and will pass the #{blue('--sandbox')} argument to that task.
          The #{blue('--')} is used to separate tomo options from options that are passed
          to the task. If a task does not accept options, the #{blue('--')} can be omitted,
          like this:

            #{blue('tomo run core:clean_releases')}

          When you specify a task name, the #{blue('run')} command is implied and can be
          omitted, so this works as well:

            #{blue('tomo core:clean_releases')}

          You can run any task defined by plugins loaded in #{DEFAULT_CONFIG_PATH}.
          To see a list of available tasks, run #{blue('tomo tasks')}.

          Tomo will auto-complete this command’s options, including the #{yellow('TASK')} name,
          if you are using bash and have tomo’s completion script installed. For
          installation instructions, run #{blue('tomo completion-script')}.

          For more documentation and examples, visit:

            #{blue('https://tomo.mattbrictson.com/commands/run')}
        BANNER
      end

      def call(task, *args, options)
        logger.info "tomo run v#{Tomo::VERSION}"

        runtime = configure_runtime(options)
        plan = runtime.run!(task, *args, privileged: options[:privileged])
        log_completion(task, plan)
      end

      private

      def log_completion(task, plan)
        target = "#{task} on #{plan.applicable_hosts_sentence}"

        if dry_run?
          logger.info(green("* Simulated #{target} (dry run)"))
        else
          logger.info(green("✔ Ran #{target}"))
        end
      end

      def task_names(*, options)
        runtime = configure_runtime(options, strict: false)
        runtime.tasks
      end
    end
  end
end
