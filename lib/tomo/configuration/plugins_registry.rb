module Tomo
  class Configuration
    class PluginsRegistry
      attr_reader :helper_modules

      def initialize(settings_registry:, tasks_registry:)
        @helper_modules = []
        @settings_registry = settings_registry
        @tasks_registry = tasks_registry
      end

      def core_loaded?
        return false unless defined?(Tomo::Plugin::Core::Plugin)

        helper_modules.include?(Tomo::Plugin::Core::Plugin)
      end

      def load_plugin_by_name(name)
        plugin = PluginResolver.resolve(name)
        load_plugin(name, plugin)
      end

      def load_plugin_from_path(path)
        name = File.basename(path).sub(/\.rb$/i, "")

        # TODO: error handling for file-not-found
        Tomo.logger.debug("Loading plugin from #{path.inspect}")
        script = IO.read(path)
        plugin = define_anonymous_plugin_class(path)
        plugin.class_eval(script, path.to_s, 1)

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

      def define_anonymous_plugin_class(name)
        plugin = Class.new(TaskLibrary)
        plugin.extend(PluginDSL)
        plugin.send(:tasks, plugin)
        plugin.define_singleton_method(:to_s) do
          super().sub(/>$/, "(#{name})>")
        end
        plugin
      end
    end
  end
end
