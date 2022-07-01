module Tomo
  class Configuration
    class PluginsRegistry
      autoload :FileResolver, "tomo/configuration/plugins_registry/file_resolver"
      autoload :GemResolver, "tomo/configuration/plugins_registry/gem_resolver"

      attr_reader :helper_modules, :settings

      def initialize
        @settings = {}
        @helper_modules = []
        @namespaced_classes = []
      end

      def task_names
        bind_tasks(nil).keys
      end

      def bind_tasks(context)
        namespaced_classes.each_with_object({}) do |(namespace, klass), result|
          library = klass.new(context)

          klass.public_instance_methods(false).each do |name|
            qualified = [namespace, name].compact.join(":")
            result[qualified] = library.public_method(name)
          end
        end
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
        settings.merge!(plugin_class.default_settings) { |_, exist, _| exist }
        register_task_libraries(namespace, *plugin_class.tasks_classes)
      end

      private

      attr_reader :namespaced_classes

      def register_task_libraries(namespace, *library_classes)
        library_classes.each { |cls| register_task_library(namespace, cls) }
      end

      def register_task_library(namespace, library_class)
        Tomo.logger.debug("Registering task library #{library_class} (#{namespace.inspect} namespace)")
        namespaced_classes << [namespace, library_class]
      end
    end
  end
end
