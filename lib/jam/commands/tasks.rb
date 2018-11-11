module Jam
  module Commands
    class Tasks
      def parser
        Jam::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: jam tasks

            Lists all jam tasks (i.e. those that can be used with `jam run`).

            Available tasks are those defined by plugins loaded in .jam/project.json,
            or can also be custom tasks defined in .jam/tasks.rb.
          BANNER
          parser.permit_empty_args = true
        end
      end

      def call(_options)
        jam = Jam.load!(environment: :auto)

        groups = jam.tasks.group_by { |task| task[/^([^:]+):/, 1].to_s }
        groups.keys.sort.each do |group|
          puts groups[group].sort.join("\n")
        end
      end
    end
  end
end
