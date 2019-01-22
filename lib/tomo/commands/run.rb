require "time"

module Tomo
  module Commands
    class Run
      include Colors

      # rubocop:disable Metrics/MethodLength
      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo run [options] [--] TASK [ARGS...]

            Remotely run one specified TASK, optionally passing ARGS to that task.
            For example, if this project uses the "rails" plugin, you could run:

              tomo run -- rails:console --sandbox

            This will run the `rails:console` task on the host specified in
            .tomo/project.json, and will pass the `--sandbox` argument to that task.
            The `--` is used to separate tomo options from options that are passed
            to the task. If a task does not accept options, the `--` can be omitted.

            Available tasks are those defined by plugins loaded in .tomo/project.json,
            or can also be custom tasks defined in .tomo/tasks.rb. To see a list of
            available tasks, run:

              tomo tasks
          BANNER
          parser.permit_extra_args = true
          parser.add(Tomo::CLI::DeployOptions)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def call(options)
        Tomo.logger.info "tomo run v#{Tomo::VERSION}"

        start_time = Time.now
        task, *args = options[:extra_args]
        project = load_project!(options, args, start_time)

        plan = project.build_run_plan(task)
        plan.run

        log_completion(task, plan)
      end

      private

      def log_completion(task, plan)
        target = "#{task} on #{plan.applicable_hosts_sentence}"

        if Tomo.dry_run?
          Tomo.logger.info(green("* Simulated #{target} (dry run)"))
        else
          Tomo.logger.info(green("✔ Ran #{target}"))
        end
      end

      def load_project!(options, args, start_time)
        Tomo.load_project!(
          environment: options[:environment],
          settings: options[:settings].merge(
            options[:settings].merge(run_args: args, start_time: start_time)
          )
        )
      end
    end
  end
end
