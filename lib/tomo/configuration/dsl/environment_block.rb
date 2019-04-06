module Tomo
  class Configuration
    module DSL
      class EnvironmentBlock
        include HostsAndSettings

        def initialize(config)
          @config = config
        end
      end
    end
  end
end
