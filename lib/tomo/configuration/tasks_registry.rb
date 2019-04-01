module Tomo
  class Configuration
    class TasksRegistry
      def initialize
        @namespaced_classes = []
      end

      def bind_tasks(context)
        namespaced_classes.each_with_object({}) do |(namespace, klass), result|
          library = klass.new(context)

          klass.public_instance_methods(false).each do |name|
            qualified = [namespace, name].compact.join(":")
            result[qualified] = library.public_method(name)
          end
        end
      end

      def register_task_libraries(namespace, *library_classes)
        library_classes.each { |cls| register_task_library(namespace, cls) }
      end

      def register_task_library(namespace, library_class)
        Tomo.logger.debug(
          "Registering task library #{library_class}"\
          " (#{namespace.inspect} namespace)"
        )
        namespaced_classes << [namespace, library_class]
      end

      private

      attr_reader :namespaced_classes
    end
  end
end
