module Jam
  class Framework
    class Current
      def [](attrib)
        fiber_locals[attrib]
      end

      def set(new_attributes)
        old_attributes = slice(*new_attributes.keys)
        fiber_locals.merge!(new_attributes)
        yield
      ensure
        fiber_locals.merge!(old_attributes)
      end

      private

      def slice(*keys)
        Hash[keys.map { |key| [key, fiber_locals[key]] }]
      end

      def fiber_locals
        Thread.current["Jam::Framework::Current@#{object_id}"] ||= {}
      end
    end
  end
end
