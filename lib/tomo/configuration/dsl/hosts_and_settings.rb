module Tomo
  class Configuration
    module DSL
      module HostsAndSettings
        def set(settings)
          @config.settings.merge!(settings)
          self
        end

        def host(address, port: 22, roles: [], log_prefix: nil, privileged_user: "root")
          @config.hosts << Host.parse(
            address,
            privileged_user: privileged_user,
            port: port,
            roles: roles,
            log_prefix: log_prefix
          )
          self
        end
      end
    end
  end
end
