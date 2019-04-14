module Tomo
  class Configuration
    module DSL
      class ConfigFile
        include HostsAndSettings

        def initialize(config)
          @config = config
        end

        def plugin(name)
          @config.plugins << name.to_s
          self
        end

        def role(name, runs:)
          @config.task_filter.add_role(name, runs)
          self
        end

        def environment(name, &block)
          environment = @config.environments[name.to_s] ||= Environment.new
          EnvironmentBlock.new(environment).instance_eval(&block)
          self
        end

        def deploy(&block)
          TasksBlock.new(@config.deploy_tasks).instance_eval(&block)
          self
        end

        def setup(&block)
          TasksBlock.new(@config.setup_tasks).instance_eval(&block)
          self
        end
      end
    end
  end
end
