module Tomo
  class Host
    PATTERN = /^(?:(\S+)@)?(\S*?)$/
    private_constant :PATTERN

    attr_reader :address, :log_prefix, :user, :port, :roles, :as_privileged

    def self.parse(host, **kwargs)
      host = host.to_s.strip
      user, address = host.match(PATTERN).captures
      raise ArgumentError, "host cannot be blank" if address.empty?

      new(user: user, address: address, **kwargs)
    end

    def initialize(address:, port: nil, log_prefix: nil, roles: nil, user: nil, privileged_user: "root")
      @user = user.freeze
      @port = (port || 22).to_i.freeze
      @address = address.freeze
      @log_prefix = log_prefix.freeze
      @roles = Array(roles).map(&:freeze).freeze
      @as_privileged = privileged_copy(privileged_user)
      freeze
    end

    def with_log_prefix(prefix)
      copy = dup
      copy.instance_variable_set(:@log_prefix, prefix)
      copy.freeze
    end

    def to_s
      str = user ? "#{user}@#{address}" : address
      str << ":#{port}" unless port == 22
      str
    end

    def to_ssh_args
      args = [user ? "#{user}@#{address}" : address]
      args.push("-p", port.to_s) unless port == 22
      args
    end

    private

    def privileged_copy(priv_user)
      return self if user == priv_user

      new_prefix = Colors.red([log_prefix, priv_user].compact.join(":"))
      copy = dup
      copy.instance_variable_set(:@user, priv_user)
      copy.instance_variable_set(:@log_prefix, new_prefix)
      copy.freeze
    end
  end
end
