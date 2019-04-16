module Tomo
  class Configuration
    module DSL
      class TasksBlock
        def initialize(tasks)
          @tasks = tasks
        end

        def batch(&block)
          batch = []
          BatchBlock.new(batch).instance_eval(&block)
          @tasks << batch unless batch.empty?
          self
        end

        def run(task, privileged: false)
          task.extend(Runtime::PrivilegedTask) if privileged
          @tasks << task
          self
        end
      end
    end
  end
end
