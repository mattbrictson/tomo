module Tomo
  autoload :CLI, "tomo/cli"
  autoload :Colors, "tomo/colors"
  autoload :Commands, "tomo/commands"
  autoload :Error, "tomo/error"
  autoload :Framework, "tomo/framework"
  autoload :Host, "tomo/host"
  autoload :Logger, "tomo/logger"
  autoload :Path, "tomo/path"
  autoload :Paths, "tomo/paths"
  autoload :Plugin, "tomo/plugin"
  autoload :PluginDSL, "tomo/plugin_dsl"
  autoload :Project, "tomo/project"
  autoload :Remote, "tomo/remote"
  autoload :Result, "tomo/result"
  autoload :Script, "tomo/script"
  autoload :ShellBuilder, "tomo/shell_builder"
  autoload :SSH, "tomo/ssh"
  autoload :TaskLibrary, "tomo/task_library"
  autoload :VERSION, "tomo/version"

  class << self
    attr_accessor :logger
    attr_writer :debug, :dry_run

    # rubocop:disable Metrics/MethodLength
    def load_project!(environment:, settings: {}, env: ENV)
      spec = Project::Specification.from_json(".tomo/project.json")
                                   .for_environment(environment)

      framework = Framework.configure do |config|
        config.add_plugins(spec.plugins)
        if File.file?(".tomo/tasks.rb")
          config.add_task_library(TaskLibrary.from_script(".tomo/tasks.rb"))
        end
        config.add_settings(spec.settings)
        config.add_settings_from_env(env)
        config.add_settings(settings)
        config.add_settings(environment: environment)
      end

      Project.new(framework, spec)
    end
    # rubocop:enable Metrics/MethodLength

    def debug?
      !!@debug
    end

    def dry_run?
      !!@dry_run
    end

    def bundled?
      !!(defined?(Bundler) && ENV["BUNDLE_GEMFILE"])
    end
  end

  self.logger = Logger.new
end
