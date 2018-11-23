module Jam
  class Framework
    class SettingsRegistry
      def initialize
        @settings = {}
      end

      def define_settings(definitions)
        settings.merge!(symbolize(definitions)) { |_, existing, _| existing }
      end

      def assign_settings(assignments)
        settings.merge!(symbolize(assignments))
      end

      def to_hash
        Hash[settings.keys.map { |name| [name, fetch(name)] }]
      end

      private

      attr_reader :settings

      def symbolize(hash)
        hash.transform_keys(&:to_sym)
      end

      def fetch(name, stack=[])
        raise_circular_dependency_error(name, stack) if stack.include?(name)
        value = settings.fetch(name)
        return value unless value.is_a?(String)

        value.gsub(/%<(\w+)>/) do
          fetch(Regexp.last_match[1].to_sym, stack + [name])
        end
      end

      def raise_circular_dependency_error(name, stack)
        dependencies = [*stack, name].join(" -> ")
        raise "Circular dependency detected in settings: #{dependencies}"
      end
    end
  end
end
