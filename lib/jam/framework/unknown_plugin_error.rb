module Jam
  class Framework
    class UnknownPluginError < Jam::Error
      attr_accessor :name, :known_plugins

      def to_console
        error = <<~ERROR
          #{yellow(name)} is not a recognized plugin.
        ERROR

        sugg = Error::Suggestions.new(dictionary: known_plugins, word: name)
        error << sugg.to_console if sugg.any?
      end
    end
  end
end
