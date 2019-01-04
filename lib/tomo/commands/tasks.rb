module Tomo
  module Commands
    class Tasks
      def parser
        Tomo::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: tomo tasks

            Lists all tomo tasks (i.e. those that can be used with `tomo run`).

            Available tasks are those defined by plugins loaded in .tomo/project.json,
            or can also be custom tasks defined in .tomo/tasks.rb.
          BANNER
          parser.permit_empty_args = true
        end
      end

      def call(_options)
        project = Tomo.load_project!(environment: :auto)
        tasks = project.tasks

        groups = tasks.group_by { |task| task[/^([^:]+):/, 1].to_s }
        groups.keys.sort.each do |group|
          puts groups[group].sort.join("\n")
        end
      end
    end
  end
end
