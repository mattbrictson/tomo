module Jam
  class Framework
    class TasksRegistry
      def initialize(framework)
        @framework = framework
        @tasks = {}
      end

      def invoke_task(name)
        task = tasks.fetch(name.to_s) do
          raise "No task named #{name}"
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
          tasks[qualified_name] = -> { library.public_send(task_name) }
        end
      end

      private

      attr_reader :framework, :tasks
    end
  end
end
