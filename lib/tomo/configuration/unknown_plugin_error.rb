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
        if Tomo.bundled?
          "\nYou may need to add #{yellow(gem_name)} to your Gemfile."
        else
          "\nYou may need to install the #{yellow(gem_name)} gem."
        end
      end
    end
  end
end
