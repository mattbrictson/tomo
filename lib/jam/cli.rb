module Jam
  class CLI
    def deploy
      release = Time.now.utc.strftime("%Y%m%d%H%M%S")
      project = Jam.load_project!(
        environment: ARGV.first,
        settings: { release_path: "%<releases_path>/#{release}" }
      )
      jam = Jam.framework

      jam.connect(project["host"]) do
        project["deploy"].each do |task|
          jam.invoke_task(task)
        end
      end
    end
  end
end
