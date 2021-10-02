module Tomo
  class Configuration
    autoload :DSL, "tomo/configuration/dsl"
    autoload :Environment, "tomo/configuration/environment"
    autoload :Glob, "tomo/configuration/glob"
    autoload :PluginFileNotFoundError, "tomo/configuration/plugin_file_not_found_error"
    autoload :PluginsRegistry, "tomo/configuration/plugins_registry"
    autoload :ProjectNotFoundError, "tomo/configuration/project_not_found_error"
    autoload :RoleBasedTaskFilter, "tomo/configuration/role_based_task_filter"
    autoload :UnknownEnvironmentError, "tomo/configuration/unknown_environment_error"
    autoload :UnknownPluginError, "tomo/configuration/unknown_plugin_error"
    autoload :UnspecifiedEnvironmentError, "tomo/configuration/unspecified_environment_error"

    def self.from_config_rb(path=DEFAULT_CONFIG_PATH)
      ProjectNotFoundError.raise_with(path: path) unless File.file?(path)
      Tomo.logger.debug("Loading configuration from #{path.inspect}")
      config_rb = File.read(path)

      new.tap do |config|
        config.path = File.expand_path(path)
        DSL::ConfigFile.new(config).instance_eval(config_rb, path.to_s, 1)
      end
    rescue StandardError, SyntaxError => e
      raise DSL::ErrorFormatter.decorate(e, path, config_rb&.lines)
    end

    attr_accessor :environments, :deploy_tasks, :setup_tasks, :hosts, :plugins, :settings, :task_filter, :path

    def initialize
      @environments = {}
      @hosts = []
      @plugins = []
      @settings = {}
      @deploy_tasks = []
      @setup_tasks = []
      @task_filter = RoleBasedTaskFilter.new
    end

    def for_environment(environment)
      validate_environment!(environment)

      dup.tap do |copy|
        copy.environments = {}
        copy.hosts = hosts_for(environment)
        copy.settings = settings_with_env_overrides(environment)
      end
    end

    def build_runtime
      validate_environment!(nil)
      plugins_registry = register_plugins

      Runtime.new(
        deploy_tasks: deploy_tasks,
        setup_tasks: setup_tasks,
        plugins_registry: plugins_registry,
        hosts: add_log_prefixes(hosts),
        settings: { tomo_config_file_path: path }.merge(settings),
        task_filter: task_filter
      )
    end

    private

    def validate_environment!(name)
      if name.nil?
        raise_no_environment_specified unless environments.empty?
      else
        raise_unknown_environment(name) unless environments.key?(name)
      end
    end

    def hosts_for(environ)
      return hosts.dup unless environments.key?(environ)

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

    def register_plugins
      plugins_registry = PluginsRegistry.new

      (["core"] + plugins.uniq).each do |plug|
        if plug.start_with?(".", "/")
          plug = File.expand_path(plug, File.dirname(path)) unless path.nil?
          plugins_registry.load_plugin_from_path(plug)
        else
          plugins_registry.load_plugin_by_name(plug)
        end
      end

      plugins_registry
    end

    def settings_with_env_overrides(environ)
      return settings.dup unless environments.key?(environ)

      settings.merge(environments[environ].settings)
    end

    def raise_no_environment_specified
      UnspecifiedEnvironmentError.raise_with(environments: environments.keys)
    end

    def raise_unknown_environment(environ)
      UnknownEnvironmentError.raise_with(name: environ, known_environments: environments.keys)
    end
  end
end
