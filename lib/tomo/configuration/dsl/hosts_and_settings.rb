# frozen_string_literal: true

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
            privileged_user:,
            port:,
            roles:,
            log_prefix:
          )
          self
        end
      end
    end
  end
end
