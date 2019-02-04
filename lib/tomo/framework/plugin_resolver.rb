module Tomo
  class Framework
    class PluginResolver
      PLUGIN_PREFIX = "tomo/plugin".freeze
      private_constant :PLUGIN_PREFIX

      def self.resolve(name)
        new(name).plugin_module
      end

      def initialize(name)
        @name = name
      end

      def plugin_module
        plugin_path = [PLUGIN_PREFIX, name.tr("-", "/"), "plugin"].join("/")
        logging_loaded_gems { require plugin_path }

        plugin = constantize(plugin_path)
        assert_compatible_api(plugin)

        plugin
      rescue LoadError, NameError => error
        raise_unknown_plugin_error(error)
      end

      private

      attr_reader :name

      def assert_compatible_api(plugin)
        return if plugin.is_a?(::Tomo::Plugin)

        raise "#{plugin} does not extend Tomo::Plugin"
      end

      def constantize(path)
        parts = path.split("/")
        parts.reduce(Object) do |parent, part|
          child = part.gsub(/^[a-z]|_[a-z]/) { |str| str.chars.last.upcase }
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

      def logging_loaded_gems
        return yield unless Tomo.debug?

        loaded_gems = Gem.loaded_specs.keys
        yield
        new_gems = Gem.loaded_specs.keys - loaded_gems

        new_gems.each do |gem_name|
          Tomo.logger.debug(
            "Loaded #{gem_name} #{Gem.loaded_gems[gem_name].version}"
          )
        end
      end

      def scan_for_plugins
        Gem.find_latest_files("#{PLUGIN_PREFIX}/**/plugin.rb").map do |file|
          file[%r{#{PLUGIN_PREFIX}/(.+)/plugin\.rb$}, 1].tr("/", "-")
        end.uniq.sort
      end
    end
  end
end
