module Tomo
  class Configuration
    module DSL
      autoload :BatchBlock, "tomo/configuration/dsl/batch_block"
      autoload :ConfigFile, "tomo/configuration/dsl/config_file"
      autoload :EnvironmentBlock, "tomo/configuration/dsl/environment_block"
      autoload :ErrorFormatter, "tomo/configuration/dsl/error_formatter"
      autoload :HostsAndSettings, "tomo/configuration/dsl/hosts_and_settings"
      autoload :TasksBlock, "tomo/configuration/dsl/tasks_block"
    end
  end
end
