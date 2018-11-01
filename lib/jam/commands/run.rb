module Jam
  module Commands
    class Run
      def call(args)
        parser = Jam::CLI::Parser.new
        parser.add(Jam::CLI::DeployOptions)
        options = parser.parse(args, permit_extra_args: true)

        task, *args = options[:extra_args]

        project = Jam.load_project!(
          environment: options[:environment],
          settings: options[:settings].merge(run_args: args)
        )

        Jam.framework.connect(project["host"]) do
          Jam.framework.invoke_task(task)
        end
      end
    end
  end
end
