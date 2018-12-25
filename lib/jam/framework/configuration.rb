module Jam
  class Framework
    class Configuration
      def self.configure
        config = Configuration.new
        yield(config) if block_given?
        config.build_framework
      end

      def add_plugins(plugins)
        plugins_registry.load_plugins_by_name(plugins)
      end

      def add_settings(settings)
        settings_registry.assign_settings(settings)
      end

      def add_task_library(task_library)
        return if task_library.nil?

        tasks_registry.register_task_library(nil, task_library)
      end

      def build_framework
        add_plugins(["core"]) unless plugins_registry.core_loaded?

        Framework.new(
          helper_modules: plugins_registry.helper_modules,
          settings: settings_registry.to_hash,
          tasks_registry: tasks_registry
        )
      end

      private

      def plugins_registry
        @plugins_registry ||= begin
          PluginsRegistry.new(
            settings_registry: settings_registry,
            tasks_registry: tasks_registry
          )
        end
      end

      def settings_registry
        @settings_registry ||= SettingsRegistry.new
      end

      def tasks_registry
        @tasks_registry ||= TasksRegistry.new
      end
    end
  end
end
