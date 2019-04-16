module Tomo
  class Configuration
    module DSL
      class BatchBlock
        def initialize(batch)
          @batch = batch
        end

        def run(task, privileged: false)
          task.extend(Runtime::PrivilegedTask) if privileged
          @batch << task
          self
        end
      end
    end
  end
end
