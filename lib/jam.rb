module Jam
  autoload :CLI, "jam/cli"
  autoload :DSL, "jam/dsl"
  autoload :Error, "jam/errors"
  autoload :Framework, "jam/framework"
  autoload :Path, "jam/path"
  autoload :Paths, "jam/paths"
  autoload :Plugin, "jam/plugin"
  autoload :Plugins, "jam/plugins"
  autoload :Remote, "jam/remote"
  autoload :Result, "jam/result"
  autoload :ShellCommand, "jam/shell_command"
  autoload :SSH, "jam/ssh"
  autoload :VERSION, "jam/version"

  class << self
    def load!(settings:{})
      @framework = Framework.new.load!(settings: settings)
    end

    def load_project!(environment: nil, settings:{})
      @framework = Framework.new
      @framework.load_project!(environment: environment, settings: settings)
    end

    def framework
      @framework || raise("Jam has not been loaded. Call `Jam.load!` first.")
    end
  end
end
