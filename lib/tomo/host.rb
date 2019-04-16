module Tomo
  class Host
    PATTERN = /^(?:(\S+)@)?(\S*?)(?::(\S+))?$/.freeze
    private_constant :PATTERN

    attr_reader :address, :log_prefix, :user, :port, :roles, :as_privileged

    def self.parse(host)
      return host if host.is_a?(Host)

      host = host.to_s.strip
      user, address, port = host.match(PATTERN).captures
      raise ArgumentError, "host cannot be blank" if address.empty?

      new(user: user, port: port, address: address)
    end

    # rubocop:disable Metrics/ParameterLists
    def initialize(address:, port: nil, log_prefix: nil, roles: nil,
                   user: nil, privileged_user: "root")
      @user = user.freeze
      @port = (port || 22).to_s.freeze
      @address = address.freeze
      @log_prefix = log_prefix.freeze
      @roles = Array(roles).map(&:freeze).freeze
      @as_privileged = privileged_copy(privileged_user)
      freeze
    end
    # rubocop:enable Metrics/ParameterLists

    def with_log_prefix(prefix)
      self.class.new(
        address: address,
        port: port,
        user: user,
        roles: roles,
        log_prefix: prefix
      )
    end

    def to_s
      str = user ? "#{user}@#{address}" : address
      str << ":#{port}" unless port == "22"
      str
    end

    def to_ssh_args
      args = [user ? "#{user}@#{address}" : address]
      args.push("-p", port) unless port == "22"
      args
    end

    private

    def privileged_copy(priv_user)
      return self if user == priv_user

      pre = [log_prefix, Colors.red(priv_user)].compact.join(Colors.gray(":"))
      self.class.new(
        address: address,
        port: port,
        user: priv_user,
        privileged_user: priv_user,
        roles: roles,
        log_prefix: pre
      )
    end
  end
end
