module Tomo
  class Configuration
    module DSL
      class BatchBlock
        def initialize(batch)
          @batch = batch
        end

        def run(task, priviliged: false)
          task.extend(Runtime::PriviligedTask) if priviliged
          @batch << task
          self
        end
      end
    end
  end
end
