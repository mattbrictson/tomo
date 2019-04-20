module Tomo
  class Configuration
    class PluginsRegistry
      autoload :FileResolver,
               "tomo/configuration/plugins_registry/file_resolver"
      autoload :GemResolver, "tomo/configuration/plugins_registry/gem_resolver"

      attr_reader :helper_modules

      def initialize(settings_registry:, tasks_registry:)
        @helper_modules = []
        @settings_registry = settings_registry
        @tasks_registry = tasks_registry
      end

      def load_plugin_by_name(name)
        plugin = GemResolver.resolve(name)
        load_plugin(name, plugin)
      end

      def load_plugin_from_path(path)
        name = File.basename(path).sub(/\.rb$/i, "")
        plugin = FileResolver.resolve(path)
        load_plugin(name, plugin)
      end

      def load_plugin(namespace, plugin_class)
        Tomo.logger.debug("Loading plugin #{plugin_class}")

        helper_modules.push(*plugin_class.helper_modules)
        settings_registry.define_settings(plugin_class.default_settings)
        tasks_registry.register_task_libraries(
          namespace,
          *plugin_class.tasks_classes
        )
      end

      private

      attr_reader :settings_registry, :tasks_registry
    end
  end
end
