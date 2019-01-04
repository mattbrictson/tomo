require "forwardable"

module Tomo
  class Framework
    extend Forwardable

    autoload :ConcurrentRubyLoadError,
             "tomo/framework/concurrent_ruby_load_error"
    autoload :ConcurrentRubyThreadPool,
             "tomo/framework/concurrent_ruby_thread_pool"
    autoload :Configuration, "tomo/framework/configuration"
    autoload :Current, "tomo/framework/current"
    autoload :ExecutionPlan, "tomo/framework/execution_plan"
    autoload :Glob, "tomo/framework/glob"
    autoload :InlineThreadPool, "tomo/framework/inline_thread_pool"
    autoload :PluginsRegistry, "tomo/framework/plugins_registry"
    autoload :RolesFilter, "tomo/framework/roles_filter"
    autoload :SettingsRegistry, "tomo/framework/settings_registry"
    autoload :TasksRegistry, "tomo/framework/tasks_registry"
    autoload :UnknownPluginError, "tomo/framework/unknown_plugin_error"

    class << self
      def configure(&block)
        Configuration.configure(&block)
      end
    end

    attr_reader :helper_modules, :paths, :settings

    def initialize(helper_modules:, settings:, tasks_registry:)
      @helper_modules = helper_modules.freeze
      @paths = Paths.new(settings)
      @settings = settings.freeze
      @tasks_by_name = tasks_registry.bind_tasks(self).freeze
      freeze
    end

    def tasks
      tasks_by_name.keys
    end

    def execute(task:, remote:)
      Current.with(remote: remote) do
        invoke_task(task)
      end
    end

    def connect(host)
      Current.with(host: host) do
        conn = SSH.connect(host: host, options: SSH::Options.new(settings))
        remote = Remote.new(conn, self)
        return remote unless block_given?

        begin
          return yield(remote)
        ensure
          remote&.close if block_given?
        end
      end
    end

    private

    attr_reader :tasks_by_name

    def invoke_task(name)
      name = name.to_s
      task = tasks_by_name.fetch(name) do
        raise_no_task_found(name)
      end

      Current.with(task: name) do
        Tomo.logger.task_start(name)
        task.call
      end
    end

    def raise_no_task_found(name)
      UnknownTaskError.raise_with(
        name,
        unknown_task: name,
        known_tasks: tasks
      )
    end
  end
end
