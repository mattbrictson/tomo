module Jam
  module Commands
    class Deploy
      def call(options)
        release = Time.now.utc.strftime("%Y%m%d%H%M%S")
        project = Jam.load_project!(
          environment: options.environment,
          settings: options.settings.merge(
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
