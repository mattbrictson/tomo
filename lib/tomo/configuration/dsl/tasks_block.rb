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

        def run(task, priviliged: false)
          task.extend(Runtime::PriviligedTask) if priviliged
          @tasks << task
          self
        end
      end
    end
  end
end
