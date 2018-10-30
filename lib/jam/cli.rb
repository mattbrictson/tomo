require "optparse"

# TODO: refactor this entire thing
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Jam
  class CLI
    def deploy
      release = Time.now.utc.strftime("%Y%m%d%H%M%S")
      settings = { release_path: "%<releases_path>/#{release}" }
      environment = nil

      OptionParser.new do |opts|
        opts.banner = "Usage: jam [options]"
        opts.on("-s", "--setting=NAME=VALUE") do |setting|
          name, value = setting.split("=", 2)
          settings[name.to_sym] = value
        end
        opts.on("-e", "--environment=ENVIRONMENT") do |env|
          environment = env
        end
        opts.on("-v", "--version") do
          puts "jam #{Jam::VERSION}"
          exit
        end
        opts.on("-h", "--help") do
          puts opts
          exit
        end
      end.parse!

      project = Jam.load_project!(
        environment: environment,
        settings: settings
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
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
