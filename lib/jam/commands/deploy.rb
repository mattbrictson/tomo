module Jam
  module Commands
    class Deploy
      def call(args)
        parser = Jam::CLI::Parser.new
        parser.add(Jam::CLI::DeployOptions)
        options = parser.parse(args)

        release = Time.now.utc.strftime("%Y%m%d%H%M%S")
        project = Jam.load_project!(
          environment: options[:environment],
          settings: options[:settings].merge(
            release_path: "%<releases_path>/#{release}"
          )
        )
        Jam.framework.connect(project["host"]) do
          project["deploy"].each do |task|
            Jam.framework.invoke_task(task)
          end
        end
      end
    end
  end
end
