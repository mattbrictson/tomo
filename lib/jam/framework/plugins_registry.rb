module Jam
  class Framework
    class PluginsRegistry
      BUILT_IN_PLUGINS = {
        "core" => "Jam::Plugins::Core::Plugin",
        "bundler" => "Jam::Plugins::Bundler::Plugin",
        "git" => "Jam::Plugins::Git::Plugin",
        "rails" => "Jam::Plugins::Rails::Plugin"
      }.freeze
      private_constant :BUILT_IN_PLUGINS

      attr_reader :helper_modules

      def initialize(settings_registry:, tasks_registry:)
        @helper_modules = []
        @settings_registry = settings_registry
        @tasks_registry = tasks_registry
      end

      def load_plugin_by_name(name)
        raise unless BUILT_IN_PLUGINS.key?(name)

        load_plugin(name, Jam.const_get(BUILT_IN_PLUGINS[name]))
      end

      def load_plugin(namespace, plugin_class)
        helper_modules.push(*plugin_class.helper_modules)
        settings_registry.define(plugin_class.default_settings)
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
