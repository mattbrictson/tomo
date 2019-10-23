module Tomo
  class Runtime
    class SettingsInterpolation
      def self.interpolate(settings)
        new(settings).call
      end

      def initialize(settings)
        @settings = symbolize(settings)
        @deprecation_warnings = []
      end

      def call
        hash = Hash[settings.keys.map { |name| [name, fetch(name)] }]
        dump_settings(hash) if Tomo.debug?
        print_deprecation_warnings
        hash
      end

      private

      attr_reader :settings, :deprecation_warnings

      # rubocop:disable Metrics/AbcSize
      def fetch(name, stack=[])
        raise_circular_dependency_error(name, stack) if stack.include?(name)
        value = settings.fetch(name)
        return value unless value.is_a?(String)

        value.gsub(/%{(\w+)}|%<(\w+)>/) do
          token = Regexp.last_match[1] || Regexp.last_match[2]
          deprecation_warnings << name if Regexp.last_match[2]

          fetch(token.to_sym, stack + [name])
        end
      end
      # rubocop:enable Metrics/AbcSize

      def raise_circular_dependency_error(name, stack)
        dependencies = [*stack, name].join(" -> ")
        raise "Circular dependency detected in settings: #{dependencies}"
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def print_deprecation_warnings
        return if deprecation_warnings.empty?

        examples = ""
        deprecation_warnings.uniq.each do |name|
          sett = settings[name].inspect
          old_syntax = sett.gsub(
            /%<(\w+)>/,
            Colors.red("%<") + '\1' + Colors.red(">")
          )
          new_syntax = sett.gsub(
            /%<(\w+)>/,
            Colors.green("%{") + '\1' + Colors.green("}")
          )

          examples << "\n:#{name}\n\n"
          examples << "  Replace:   set #{name}: #{old_syntax}\n"
          examples << "  with this: set #{name}: #{new_syntax}\n"
        end

        Tomo.logger.warn <<~WARNING
          There are settings using the deprecated %<...> interpolation syntax.
          #{examples}
          #{Colors.red('The %<...> syntax will not work in future versions of tomo.')}

        WARNING

        # Make sure people see the warning!
        sleep 5
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

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
