module Tomo
  class Runtime
    class UnknownTaskError < Error
      attr_accessor :unknown_task, :known_tasks

      def to_console
        error = <<~ERROR
          #{yellow(unknown_task)} is not a recognized task.
          To see a list of all available tasks, run #{blue('tomo tasks')}.
        ERROR

        sugg = spelling_suggestion || missing_plugin_suggestion
        error << sugg if sugg
        error
      end

      private

      def spelling_suggestion
        sugg = Error::Suggestions.new(dictionary: known_tasks, word: unknown_task)
        sugg.to_console if sugg.any?
      end

      def missing_plugin_suggestion
        unknown_plugin = unknown_task[/\A(.+?):/, 1]
        known_plugins = known_tasks.map { |t| t.split(":").first }.uniq
        return if unknown_plugin.nil? || known_plugins.include?(unknown_plugin)

        "\nDid you forget to install the #{blue(unknown_plugin)} plugin?"
      end
    end
  end
end
