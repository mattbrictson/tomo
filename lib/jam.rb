module Jam
  autoload :CLI, "jam/cli"
  autoload :Colors, "jam/colors"
  autoload :Commands, "jam/commands"
  autoload :Error, "jam/error"
  autoload :Framework, "jam/framework"
  autoload :Host, "jam/host"
  autoload :Logger, "jam/logger"
  autoload :Path, "jam/path"
  autoload :Paths, "jam/paths"
  autoload :Plugin, "jam/plugin"
  autoload :Plugins, "jam/plugins"
  autoload :Project, "jam/project"
  autoload :Remote, "jam/remote"
  autoload :Result, "jam/result"
  autoload :Script, "jam/script"
  autoload :ShellBuilder, "jam/shell_builder"
  autoload :SSH, "jam/ssh"
  autoload :TaskLibrary, "jam/task_library"
  autoload :UnknownTaskError, "jam/errors/unknown_task_error"
  autoload :VERSION, "jam/version"

  class << self
    attr_accessor :logger
    attr_writer :debug

    def load_project!(environment:, settings: {})
      spec = Project::Specification.from_json(".jam/project.json")
                                   .for_environment(environment)

      framework = Framework.configure do |config|
        config.add_plugins(spec.plugins)
        config.add_settings(spec.settings.merge(settings))
        if File.file?(".jam/tasks.rb")
          config.add_task_library(TaskLibrary.from_script(".jam/tasks.rb"))
        end
      end

      Project.new(framework, spec)
    end

    def debug?
      !!@debug
    end
  end

  self.logger = Logger.new
end
