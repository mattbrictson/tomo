module Tomo
  class Configuration
    module DSL
      module HostsAndSettings
        def set(settings)
          @config.settings.merge!(settings)
          self
        end

        def host(address, roles: [], log_prefix: nil)
          parsed = Host.parse(address)
          @config.hosts << Host.new(
            address: parsed.address,
            user: parsed.user,
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
