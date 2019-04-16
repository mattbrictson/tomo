module Tomo
  class Configuration
    module DSL
      module HostsAndSettings
        def set(settings)
          @config.settings.merge!(settings)
          self
        end

        def host(address, roles: [], log_prefix: nil, privileged_user: "root")
          parsed = Host.parse(address)
          @config.hosts << Host.new(
            address: parsed.address,
            user: parsed.user,
            privileged_user: privileged_user,
            port: parsed.port,
            roles: roles,
            log_prefix: log_prefix
          )
          self
        end
      end
    end
  end
end
