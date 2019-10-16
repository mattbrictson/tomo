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
        hash = Hash[settings.keys.map { |name| [name, fetch(name)] }]
        dump_settings(hash) if Tomo.debug?
        hash
      end

      private

      attr_reader :settings

      # rubocop:disable Metrics/AbcSize
      def fetch(name, stack=[])
        raise_circular_dependency_error(name, stack) if stack.include?(name)
        value = settings.fetch(name)
        return value unless value.is_a?(String)

        value.gsub(/%{(\w+)}|%<(\w+)>/) do
          token = Regexp.last_match[1] || Regexp.last_match[2]
          warn_deprecated_syntax(name, token) if Regexp.last_match[2]

          fetch(token.to_sym, stack + [name])
        end
      end
      # rubocop:enable Metrics/AbcSize

      def raise_circular_dependency_error(name, stack)
        dependencies = [*stack, name].join(" -> ")
        raise "Circular dependency detected in settings: #{dependencies}"
      end

      def warn_deprecated_syntax(name, token)
        Tomo.logger.warn <<~WARNING
          :#{name} is using the deprecated %<...> interpolation syntax.
            Replace:   %<#{token}>
            with this: %{#{token}}
          The %<...> syntax will not work in future versions of tomo.

        WARNING
      end

      def symbolize(hash)
        hash.each_with_object({}) do |(key, value), symbolized|
          symbolized[key.to_sym] = value
        end
      end

      def dump_settings(hash)
        key_len = hash.keys.map(&:to_s).map(&:length).max
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
