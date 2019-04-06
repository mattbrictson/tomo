module Tomo
  class Configuration
    module DSL
      class DeployBlock
        def initialize(config)
          @config = config
        end

        def batch(&block)
          tasks = []
          BatchBlock.new(tasks).instance_eval(&block)
          @config.deploy_tasks << tasks unless tasks.empty?
          self
        end

        def run(task)
          @config.deploy_tasks << task
          self
        end
      end
    end
  end
end
