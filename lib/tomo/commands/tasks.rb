module Tomo
  module Commands
    class Tasks < CLI::Command
      include CLI::ProjectOptions
      include CLI::CommonOptions

      def summary
        "List all tasks that can be used with the #{yellow('run')} command"
      end

      def banner
        <<~BANNER
          Usage: #{green('tomo tasks')}

          List all tomo tasks (i.e. those that can be used with #{blue('tomo run')}).

          Available tasks are those defined by plugins loaded in #{DEFAULT_CONFIG_PATH}.
        BANNER
      end

      def call(options)
        runtime = configure_runtime(options, strict: false)
        tasks = runtime.tasks

        groups = tasks.group_by { |task| task[/^([^:]+):/, 1].to_s }
        groups.keys.sort.each do |group|
          logger.info(groups[group].sort.join("\n"))
        end
      end
    end
  end
end
