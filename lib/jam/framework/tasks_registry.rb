module Jam
  class Framework
    class TasksRegistry
      def initialize(framework)
        @framework = framework
        @tasks_by_name = {}
      end

      def tasks
        tasks_by_name.keys.freeze
      end

      def invoke_task(name)
        task = tasks_by_name.fetch(name.to_s) do
          raise_no_task_found(name.to_s)
        end
        task.call
      end

      def register_task_libraries(namespace, *library_classes)
        library_classes.each { |cls| register_task_library(namespace, cls) }
      end

      def register_task_library(namespace, library_class)
        library = library_class.new(framework)
        library_class.public_instance_methods(false).each do |task_name|
          qualified_name = [namespace, task_name].compact.join(":")
          tasks_by_name[qualified_name] = -> { library.public_send(task_name) }
        end
      end

      private

      attr_reader :framework, :tasks_by_name

      def raise_no_task_found(name)
        message = "No task named #{name.inspect}"
        if defined?(DidYouMean::SpellChecker)
          checker = DidYouMean::SpellChecker.new(dictionary: tasks_by_name.keys)
          sugg = checker.correct(name)
          if sugg&.any?
            message << ". Did you mean? #{sugg.map(&:inspect).join(", ")}"
          end
        end

        raise message
      end
    end
  end
end
