module Jam
  module Commands
    class Deploy < Jam::CLI::Command
      def parser
        Jam::CLI::Parser.new do |parser|
          parser.banner = <<~BANNER
            Usage: jam deploy [options]

            Run the "deploy" script specified in .jam/project.json to deploy this project.
            For projects that have more than one environment (e.g. staging, production),
            specify the target environment using the `-e` option.
          BANNER
          parser.permit_empty_args = true
          parser.add(Jam::CLI::DeployOptions)
        end
      end

      def call(options)
        release = Time.now.utc.strftime("%Y%m%d%H%M%S")
        load_project!(options, release)
        app = settings[:application]

        logger.info "jam deploy v#{Jam::VERSION}"
        run_deploy_tasks_on_host
        logger.info green("✔ Deployed #{app} to #{project['host']}")
      end

      private

      def load_project!(options, release)
        load!(
          environment: options[:environment],
          settings: options[:settings].merge(
            release_path: "%<releases_path>/#{release}"
          )
        )
      end

      def run_deploy_tasks_on_host
        connect(project["host"]) do
          project["deploy"].each do |task|
            invoke_task(task)
          end
        end
      end
    end
  end
end
