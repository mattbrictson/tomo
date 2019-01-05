module Tomo
  class UnknownTaskError < Error
    attr_accessor :unknown_task, :known_tasks

    def to_console
      error = <<~ERROR
        #{yellow(unknown_task)} is not a recognized task.
        To see a list of all available tasks, run #{tomo('tasks')}.
      ERROR

      sugg = Error::Suggestions.new(dictionary: known_tasks, word: unknown_task)
      error << sugg.to_console if sugg.any?
      error
    end
  end
end
