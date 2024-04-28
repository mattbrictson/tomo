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

        def environment(name, &)
          environment = @config.environments[name.to_s] ||= Environment.new
          EnvironmentBlock.new(environment).instance_eval(&)
          self
        end

        def deploy(&)
          TasksBlock.new(@config.deploy_tasks).instance_eval(&)
          self
        end

        def setup(&)
          TasksBlock.new(@config.setup_tasks).instance_eval(&)
          self
        end
      end
    end
  end
end
