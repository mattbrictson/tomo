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
  autoload :Plugins, "tomo/plugins"
  autoload :Project, "tomo/project"
  autoload :Remote, "tomo/remote"
  autoload :Result, "tomo/result"
  autoload :Script, "tomo/script"
  autoload :ShellBuilder, "tomo/shell_builder"
  autoload :SSH, "tomo/ssh"
  autoload :TaskLibrary, "tomo/task_library"
  autoload :UnknownTaskError, "tomo/errors/unknown_task_error"
  autoload :VERSION, "tomo/version"

  class << self
    attr_accessor :logger
    attr_writer :debug, :dry_run

    def load_project!(environment:, settings: {})
      spec = Project::Specification.from_json(".tomo/project.json")
                                   .for_environment(environment)

      framework = Framework.configure do |config|
        config.add_plugins(spec.plugins)
        config.add_settings(spec.settings.merge(settings))
        if File.file?(".tomo/tasks.rb")
          config.add_task_library(TaskLibrary.from_script(".tomo/tasks.rb"))
        end
      end

      Project.new(framework, spec)
    end

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
