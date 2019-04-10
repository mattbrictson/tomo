module Tomo
  class Configuration
    module DSL
      autoload :BatchBlock, "tomo/configuration/dsl/batch_block"
      autoload :ConfigFile, "tomo/configuration/dsl/config_file"
      autoload :DeployBlock, "tomo/configuration/dsl/deploy_block"
      autoload :EnvironmentBlock, "tomo/configuration/dsl/environment_block"
      autoload :ErrorFormatter, "tomo/configuration/dsl/error_formatter"
      autoload :HostsAndSettings, "tomo/configuration/dsl/hosts_and_settings"
    end
  end
end
