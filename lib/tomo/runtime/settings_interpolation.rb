module Tomo
  class Runtime
    class SettingsInterpolation
      def self.interpolate(settings)
        new(settings).call
      end

      def initialize(settings)
        @settings = symbolize(settings)
      end

      def call
        hash = settings.keys.to_h { |name| [name, fetch(name)] }
        dump_settings(hash) if Tomo.debug?
        hash
      end

      private

      attr_reader :settings

      def fetch(name, stack=[])
        raise_circular_dependency_error(name, stack) if stack.include?(name)
        value = settings.fetch(name)
        return value unless value.is_a?(String)

        value.gsub(/%{(\w+)}/) do
          fetch(Regexp.last_match[1].to_sym, stack + [name])
        end
      end

      def raise_circular_dependency_error(name, stack)
        dependencies = [*stack, name].join(" -> ")
        raise "Circular dependency detected in settings: #{dependencies}"
      end

      def symbolize(hash)
        hash.transform_keys(&:to_sym)
      end

      def dump_settings(hash)
        key_len = hash.keys.map { |k| k.to_s.length }.max
        dump = "Settings: {\n"
        hash.to_a.sort_by(&:first).each do |key, value|
          justified_key = "#{key}:".ljust(key_len + 1)
          dump << "  #{justified_key} #{value.inspect},\n"
        end
        dump << "}"
        Tomo.logger.debug(dump)
      end
    end
  end
end
