module Tomo
  class Configuration
    class PluginsRegistry::GemResolver
      PLUGIN_PREFIX = "tomo/plugin".freeze
      private_constant :PLUGIN_PREFIX

      def self.resolve(name)
        new(name).plugin_module
      end

      def initialize(name)
        @name = name
      end

      def plugin_module
        plugin_path = [PLUGIN_PREFIX, name.tr("-", "/")].join("/")
        require plugin_path

        plugin = constantize(plugin_path)
        assert_compatible_api(plugin)

        plugin
      rescue LoadError => e
        raise unless e.message.match?(/\s#{Regexp.quote(plugin_path)}$/)

        raise_unknown_plugin_error(e)
      end

      private

      attr_reader :name

      def assert_compatible_api(plugin)
        return if plugin.is_a?(::Tomo::PluginDSL)

        raise "#{plugin} does not extend Tomo::PluginDSL"
      end

      def constantize(path)
        parts = path.split("/")
        parts.reduce(Object) do |parent, part|
          child = part.gsub(/^[a-z]|_[a-z]/) { |str| str[-1].upcase }
          parent.const_get(child, false)
        end
      end

      def raise_unknown_plugin_error(error)
        UnknownPluginError.raise_with(
          error.message,
          name: name,
          gem_name: "#{PLUGIN_PREFIX}/#{name}".tr("/", "-"),
          known_plugins: scan_for_plugins
        )
      end

      def scan_for_plugins
        Gem.find_latest_files("#{PLUGIN_PREFIX}/*.rb").map do |file|
          file[%r{#{PLUGIN_PREFIX}/(.+).rb$}o, 1].tr("/", "-")
        end.uniq.sort
      end
    end
  end
end
