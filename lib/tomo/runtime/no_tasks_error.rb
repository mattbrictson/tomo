module Tomo
  class Runtime
    class NoTasksError < Error
      attr_accessor :task_type

      def to_console
        <<~ERROR
          No #{task_type} tasks are configured.
          You can specify them using a #{yellow(task_type)} block in #{yellow(Tomo::DEFAULT_CONFIG_PATH)}.

          More configuration documentation and examples can be found here:

            #{blue('https://tomo.mattbrictson.com/configuration')}
        ERROR
      end
    end
  end
end
