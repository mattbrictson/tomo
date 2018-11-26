module Jam
  class Framework
    class TasksRegistry
      attr_reader :tasks_by_name

      def initialize(framework)
        @framework = framework
        @tasks_by_name = {}
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
        Jam.logger.debug(
          "Registering task library #{library_class}"\
          " (#{namespace.inspect} namespace)"
        )

        library = library_class.new(framework)
        library_class.public_instance_methods(false).each do |task_name|
          qualified_name = [namespace, task_name].compact.join(":")
          tasks_by_name[qualified_name] = -> { library.public_send(task_name) }
        end
      end

      private

      attr_reader :framework

      def raise_no_task_found(name)
        UnknownTaskError.raise_with(
          name,
          unknown_task: name,
          known_tasks: tasks_by_name.keys
        )
      end
    end
  end
end
