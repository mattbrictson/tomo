require "singleton"

module Jam
  class Framework
    autoload :ChildProcess, "jam/framework/child_process"
    autoload :Current, "jam/framework/current"
    autoload :PluginsRegistry, "jam/framework/plugins_registry"
    autoload :ProjectLoader, "jam/framework/project_loader"
    autoload :SettingsRegistry, "jam/framework/settings_registry"
    autoload :SSHConnection, "jam/framework/ssh_connection"

    attr_reader :paths, :settings

    def initialize
      @current = Current.new
      @helpers = [].freeze
      @settings = {}.freeze
      @paths = Paths.new(@settings)
    end

    def load!(settings: {}, plugins: ["core"])
      plugins.each { |plug| plugins_registry.load_plugin_by_name(plug) }
      settings_registry.assign(settings)
      @helpers = plugins_registry.helper_modules.freeze
      @settings = settings_registry.to_hash.freeze
      @paths = Paths.new(@settings)
      freeze
    end

    def load_project!(settings: {})
      project_loader.load_project
      load!(settings: settings)
    end

    def connect(host)
      conn = SSHConnection.new(host)
      remote = Remote.new(conn, helpers: helpers)
      current.set(remote: remote) do
        yield(remote)
      end
    ensure
      conn&.close
    end

    def current_remote
      current[:remote]
    end

    private

    attr_reader :current, :helpers

    def plugins_registry
      @plugins_registry ||= begin
        PluginsRegistry.new(settings_registry: settings_registry)
      end
    end

    def project_loader
      @project_loader ||= begin
        ProjectLoader.new(
          settings_registry: settings_registry,
          plugins_registry: plugins_registry
        )
      end
    end

    def settings_registry
      @settings_registry ||= SettingsRegistry.new
    end
  end
end
