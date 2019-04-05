module Tomo
  class Configuration
    autoload :Glob, "tomo/configuration/glob"
    autoload :PluginResolver, "tomo/configuration/plugin_resolver"
    autoload :PluginsRegistry, "tomo/configuration/plugins_registry"
    autoload :Project, "tomo/configuration/project"
    autoload :ProjectNotFoundError, "tomo/configuration/project_not_found_error"
    autoload :RoleBasedTaskFilter, "tomo/configuration/role_based_task_filter"
    autoload :SettingsRegistry, "tomo/configuration/settings_registry"
    autoload :TasksRegistry, "tomo/configuration/tasks_registry"
    autoload :UnknownEnvironmentError,
             "tomo/configuration/unknown_environment_error"
    autoload :UnknownPluginError, "tomo/configuration/unknown_plugin_error"
    autoload :UnspecifiedEnvironmentError,
             "tomo/configuration/unspecified_environment_error"

    # rubocop:disable Metrics/AbcSize
    def self.from_project(project)
      new.tap do |config|
        config.hosts.push(*project.hosts)
        config.plugins.push(*project.plugins)
        config.settings.merge!(project.settings)
        config.deploy_tasks = project.deploy_tasks
        config.task_filter = RoleBasedTaskFilter.new(project.roles)
        config.task_library_path = project.task_library_path
      end
    end
    # rubocop:enable Metrics/AbcSize

    attr_accessor :environment, :deploy_tasks, :hosts, :plugins, :settings,
                  :task_filter, :task_library_path

    def initialize(env=ENV)
      @env = env
      @hosts = []
      @plugins = []
      @settings = {}
      @deploy_tasks = []
      @task_filter = RoleBasedTaskFilter.new(nil)
    end

    # rubocop:disable Metrics/MethodLength
    def build_runtime
      init_registries
      register_plugins
      register_tasks
      register_settings

      Runtime.new(
        deploy_tasks: deploy_tasks,
        helper_modules: plugins_registry.helper_modules,
        hosts: hosts.uniq,
        settings_registry: settings_registry,
        task_filter: task_filter,
        tasks_registry: tasks_registry
      )
    end
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :env, :plugins_registry, :settings_registry, :tasks_registry

    def init_registries
      @settings_registry = SettingsRegistry.new
      @tasks_registry = TasksRegistry.new
      @plugins_registry ||= begin
        PluginsRegistry.new(
          settings_registry: settings_registry,
          tasks_registry: tasks_registry
        )
      end
    end

    def register_plugins
      plugins_registry.load_plugins_by_name(["core"] + plugins.uniq)
    end

    def register_tasks
      return if task_library_path.nil?
      return unless File.file?(task_library_path)

      task_library = TaskLibrary.from_script(task_library_path)
      tasks_registry.register_task_library(nil, task_library)
    end

    def register_settings
      settings_registry.assign_settings(settings)
    end
  end
end
