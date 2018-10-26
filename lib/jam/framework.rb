require "singleton"

module Jam
  class Framework
    autoload :ChildProcess, "jam/framework/child_process"
    autoload :Current, "jam/framework/current"
    autoload :PluginsRegistry, "jam/framework/plugins_registry"
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
      yield(self) if block_given?
      @helpers = plugins_registry.helper_modules.freeze
      @settings = settings_registry.to_hash.freeze
      @paths = Paths.new(@settings)
      freeze
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

    def settings_registry
      @settings_registry ||= SettingsRegistry.new
    end
  end
end
