module Jam
  class Framework
    module Current
      class << self
        def host
          fiber_locals[:host] || remote&.host
        end

        def remote
          fiber_locals[:remote]
        end

        def task
          fiber_locals[:task]
        end

        def with(new_locals)
          old_locals = slice(*new_locals.keys)
          fiber_locals.merge!(new_locals)
          yield
        ensure
          fiber_locals.merge!(old_locals)
        end

        def variables
          fiber_locals.dup.freeze
        end

        private

        def slice(*keys)
          Hash[keys.map { |key| [key, fiber_locals[key]] }]
        end

        def fiber_locals
          Thread.current["Jam::Framework::Current"] ||= {}
        end
      end
    end
  end
end
