module Tomo
  autoload :CLI, "tomo/cli"
  autoload :Colors, "tomo/colors"
  autoload :Commands, "tomo/commands"
  autoload :Configuration, "tomo/configuration"
  autoload :Console, "tomo/console"
  autoload :Error, "tomo/error"
  autoload :Host, "tomo/host"
  autoload :Logger, "tomo/logger"
  autoload :Path, "tomo/path"
  autoload :Paths, "tomo/paths"
  autoload :Plugin, "tomo/plugin"
  autoload :PluginDSL, "tomo/plugin_dsl"
  autoload :Remote, "tomo/remote"
  autoload :Result, "tomo/result"
  autoload :Runtime, "tomo/runtime"
  autoload :Script, "tomo/script"
  autoload :ShellBuilder, "tomo/shell_builder"
  autoload :SSH, "tomo/ssh"
  autoload :TaskAPI, "tomo/task_api"
  autoload :TaskLibrary, "tomo/task_library"
  autoload :VERSION, "tomo/version"

  DEFAULT_CONFIG_PATH = ".tomo/config.rb".freeze

  class << self
    attr_accessor :logger
    attr_writer :debug, :dry_run

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

  self.debug = false
  self.dry_run = false
  self.logger = Logger.new
end
