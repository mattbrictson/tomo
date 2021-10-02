module Tomo
  class Configuration
    class UnknownPluginError < Tomo::Error
      attr_accessor :name, :known_plugins, :gem_name

      def to_console
        error = <<~ERROR
          #{yellow(name)} is not a recognized plugin.
        ERROR

        sugg = Error::Suggestions.new(dictionary: known_plugins, word: name)
        error << sugg.to_console if sugg.any?

        error << gem_suggestion
      end

      private

      def gem_suggestion
        return "\nYou may need to add #{yellow(gem_name)} to your Gemfile." if Tomo.bundled?

        messages = ["\nYou may need to install the #{yellow(gem_name)} gem."]
        if present_in_gemfile?
          messages << "\nTry prefixing the tomo command with #{blue('bundle exec')} to fix this error."
        end

        messages.join
      end

      def present_in_gemfile?
        return false unless File.file?("Gemfile")

        File.read("Gemfile").match?(/^\s*gem ['"]#{Regexp.quote(gem_name)}['"]/)
      rescue IOError
        false
      end
    end
  end
end
