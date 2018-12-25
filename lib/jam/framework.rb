require "forwardable"

module Jam
  class Framework
    extend Forwardable

    autoload :Configuration, "jam/framework/configuration"
    autoload :PluginsRegistry, "jam/framework/plugins_registry"
    autoload :SettingsRegistry, "jam/framework/settings_registry"
    autoload :TasksRegistry, "jam/framework/tasks_registry"

    class << self
      def configure(&block)
        Configuration.configure(&block)
      end
    end

    attr_reader :helper_modules, :paths, :settings, :tasks

    def initialize(helper_modules:, settings:, tasks_registry:)
      @helper_modules = helper_modules.freeze
      @paths = Paths.new(settings)
      @settings = settings.freeze
      @tasks = tasks_registry.bind_tasks(self).freeze
      freeze
    end

    def connect(host)
      conn = SSH.connect(
        host: host,
        options: SSH::Options.new(settings)
      )
      remote = Remote.new(conn, self)
      Current.with(remote: remote) do
        yield(remote)
      end
    ensure
      conn&.close
    end

    def invoke_task(name)
      task = tasks.fetch(name.to_s) do
        raise_no_task_found(name.to_s)
      end

      Current.with(task: name) do
        Jam.logger.task_start(name)
        task.call
      end
    end

    private

    def raise_no_task_found(name)
      UnknownTaskError.raise_with(
        name,
        unknown_task: name,
        known_tasks: tasks.keys
      )
    end
  end
end
