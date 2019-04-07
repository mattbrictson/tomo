module Tomo
  class Configuration
    autoload :DSL, "tomo/configuration/dsl"
    autoload :Environment, "tomo/configuration/environment"
    autoload :Glob, "tomo/configuration/glob"
    autoload :PluginResolver, "tomo/configuration/plugin_resolver"
    autoload :PluginsRegistry, "tomo/configuration/plugins_registry"
    autoload :ProjectNotFoundError, "tomo/configuration/project_not_found_error"
    autoload :RoleBasedTaskFilter, "tomo/configuration/role_based_task_filter"
    autoload :SettingsRegistry, "tomo/configuration/settings_registry"
    autoload :TasksRegistry, "tomo/configuration/tasks_registry"
    autoload :UnknownEnvironmentError,
             "tomo/configuration/unknown_environment_error"
    autoload :UnknownPluginError, "tomo/configuration/unknown_plugin_error"
    autoload :UnspecifiedEnvironmentError,
             "tomo/configuration/unspecified_environment_error"

    def self.from_project_rb(path=".tomo/project.rb")
      ProjectNotFoundError.raise_with(path: path) unless File.file?(path)
      Tomo.logger.debug("Loading project from #{path.inspect}")
      project_rb = IO.read(path)

      new.tap do |config|
        config.task_library_path = File.expand_path("../tasks.rb", path)
        DSL::Project.new(config).instance_eval(project_rb, path.to_s, 1)
      end
    end

    attr_accessor :environments, :deploy_tasks, :hosts, :plugins, :settings,
                  :task_filter, :task_library_path

    def initialize
      @environments = Hash.new { |hash, key| hash[key] = Environment.new }
      @hosts = []
      @plugins = []
      @settings = {}
      @deploy_tasks = []
      @task_filter = RoleBasedTaskFilter.new
    end

    # rubocop:disable Metrics/MethodLength
    def build_runtime(environment: nil)
      validate_environment!(environment)

      init_registries
      register_plugins
      register_tasks
      register_settings(environment)

      Runtime.new(
        deploy_tasks: deploy_tasks,
        helper_modules: plugins_registry.helper_modules,
        hosts: add_log_prefixes(hosts_for(environment)),
        settings_registry: settings_registry,
        task_filter: task_filter,
        tasks_registry: tasks_registry
      )
    end
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :plugins_registry, :settings_registry, :tasks_registry

    def validate_environment!(name)
      if name.nil?
        raise_no_environment_specified unless environments.empty?
      else
        raise_unknown_environment(name) unless environments.key?(name)
      end
    end

    def hosts_for(environ)
      env_hosts = environments[environ].hosts
      return env_hosts unless env_hosts.empty?

      hosts
    end

    def add_log_prefixes(host_arr)
      return host_arr if host_arr.length == 1
      return host_arr unless host_arr.all? { |h| h.log_prefix.nil? }

      width = host_arr.length.to_s.length
      host_arr.map.with_index do |host, i|
        host.with_log_prefix((i + 1).to_s.rjust(width, "0"))
      end
    end

    def init_registries
      @settings_registry = SettingsRegistry.new
      @tasks_registry = TasksRegistry.new
      @plugins_registry = PluginsRegistry.new(
        settings_registry: settings_registry, tasks_registry: tasks_registry
      )
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

    def register_settings(environ)
      merged = settings.merge(environments[environ].settings)
      settings_registry.assign_settings(merged)
    end

    def raise_no_environment_specified
      UnspecifiedEnvironmentError.raise_with(environments: environments.keys)
    end

    def raise_unknown_environment(environ)
      UnknownEnvironmentError.raise_with(
        name: environ, known_environments: environments.keys
      )
    end
  end
end
