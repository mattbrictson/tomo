require "forwardable"

module Jam
  class Framework
    extend Forwardable

    autoload :ConcurrentRubyLoadError,
             "jam/framework/concurrent_ruby_load_error"
    autoload :ConcurrentRubyThreadPool,
             "jam/framework/concurrent_ruby_thread_pool"
    autoload :Configuration, "jam/framework/configuration"
    autoload :Current, "jam/framework/current"
    autoload :ExecutionPlan, "jam/framework/execution_plan"
    autoload :Glob, "jam/framework/glob"
    autoload :InlineThreadPool, "jam/framework/inline_thread_pool"
    autoload :PluginsRegistry, "jam/framework/plugins_registry"
    autoload :RolesFilter, "jam/framework/roles_filter"
    autoload :SettingsRegistry, "jam/framework/settings_registry"
    autoload :TasksRegistry, "jam/framework/tasks_registry"
    autoload :UnknownPluginError, "jam/framework/unknown_plugin_error"

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
        Jam.logger.task_start(name)
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
