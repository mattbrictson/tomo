module Jam
  class UnknownTaskError < Error
    attr_accessor :unknown_task, :known_tasks

    def to_console
      error = <<~ERROR
        #{yellow(unknown_task)} is not a recognized task.
        To see a list of all available tasks, run #{blue('jam tasks')}.
      ERROR

      error << "\nDid you mean #{suggestions}?\n" if suggestions
      error
    end

    private

    def suggestions
      return unless defined?(DidYouMean::SpellChecker)

      checker = DidYouMean::SpellChecker.new(dictionary: known_tasks)
      suggestions = checker.correct(unknown_task)
      return unless suggestions&.any?

      to_sentence(suggestions.map! { |s| blue(s) })
    end

    def to_sentence(words)
      return words.first if words.length == 1
      return words.join(" or ") if words.length == 2

      words[0...-1].join(", ") + ", or " + words.last
    end
  end
end
