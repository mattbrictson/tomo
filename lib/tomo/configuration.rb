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

    # rubocop:disable Metrics/AbcSize
    def self.from_config_rb(path=DEFAULT_CONFIG_PATH)
      ProjectNotFoundError.raise_with(path: path) unless File.file?(path)
      Tomo.logger.debug("Loading project from #{path.inspect}")
      config_rb = IO.read(path)

      new.tap do |config|
        config.working_dir = File.dirname(path)
        DSL::ConfigFile.new(config).instance_eval(config_rb, path.to_s, 1)
      end
    rescue StandardError => e
      raise DSL::ErrorFormatter.decorate(e, path, config_rb.lines)
    end
    # rubocop:enable Metrics/AbcSize

    attr_accessor :environments, :deploy_tasks, :hosts, :plugins, :settings,
                  :task_filter, :working_dir

    def initialize
      @environments = {}
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
      return hosts unless environments.key?(environ)

      environments[environ].hosts
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
      (["core"] + plugins.uniq).each do |plug|
        if %w[. /].include?(plug[0])
          plug = File.expand_path(plug, working_dir) unless working_dir.nil?
          plugins_registry.load_plugin_from_path(plug)
        else
          plugins_registry.load_plugin_by_name(plug)
        end
      end
    end

    def register_settings(environ)
      settings_registry.assign_settings(settings)
      return unless environments.key?(environ)

      settings_registry.assign_settings(environments[environ].settings)
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
