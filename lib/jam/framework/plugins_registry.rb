module Jam
  class Framework
    class PluginsRegistry
      attr_reader :helper_modules

      def initialize(settings_registry:)
        @helper_modules = []
        @settings_registry = settings_registry
      end

      def load_plugin_by_name(name)
        raise unless name == "core"

        load_plugin(Jam::Plugins::Core)
      end

      def load_plugin(plugin_class)
        helper_modules.push(*plugin_class.helper_modules)
        settings_registry.define(plugin_class.default_settings)
      end

      private

      attr_reader :settings_registry
    end
  end
end
