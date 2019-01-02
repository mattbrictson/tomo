module Jam
  module Commands
    class Deploy
      include Jam::Colors

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
        Jam.logger.info "jam deploy v#{Jam::VERSION}"

        release = Time.now.utc.strftime("%Y%m%d%H%M%S")
        project = load_project!(options, release)
        app = project.settings[:application]

        plan = project.build_deploy_plan
        plan.call
        Jam.logger.info green("✔ Deployed #{app} to #{plan.hosts_sentence}")
      end

      private

      def load_project!(options, release)
        Jam.load_project!(
          environment: options[:environment],
          settings: options[:settings].merge(
            release_path: "%<releases_path>/#{release}"
          )
        )
      end
    end
  end
end
