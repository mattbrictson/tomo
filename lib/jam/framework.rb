require "forwardable"

module Jam
  class Framework
    extend Forwardable

    autoload :PluginsRegistry, "jam/framework/plugins_registry"
    autoload :SettingsRegistry, "jam/framework/settings_registry"
    autoload :TasksRegistry, "jam/framework/tasks_registry"

    def_delegators :plugins_registry, :load_plugin_by_name, :load_plugin
    def_delegators :settings_registry, :assign_settings, :define_settings
    def_delegators :tasks_registry, :register_task_library,
                   :register_task_libraries

    attr_reader :helper_modules, :paths, :settings, :tasks

    def load_project!(environment:, settings: {})
      json = Project::JsonParser.parse(
        path: ".jam/project.json", environment: environment
      )
      (json["settings"] ||= {}).merge!(settings)

      project = Project::Loader.load!(
        framework: self, json: json, tasks_path: ".jam/tasks.rb"
      )
      ready!
      project
    end

    def ready!
      @helper_modules = plugins_registry.helper_modules.freeze
      @settings = settings_registry.to_hash.freeze
      @tasks = tasks_registry.tasks_by_name.keys.freeze
      @paths = Paths.new(@settings)
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
      Current.with(task: name) do
        Jam.logger.task_start(name)
        tasks_registry.invoke_task(name)
      end
    end

    private

    def plugins_registry
      @plugins_registry ||= begin
        PluginsRegistry.new(
          settings_registry: settings_registry,
          tasks_registry: tasks_registry
        )
      end
    end

    def settings_registry
      @settings_registry ||= SettingsRegistry.new
    end

    def tasks_registry
      @tasks_registry ||= TasksRegistry.new(self)
    end
  end
end
