module Tomo
  class Host
    PATTERN = /^(?:(\S+)@)?(\S*?)(?::(\S+))?$/.freeze
    private_constant :PATTERN

    attr_reader :address, :name, :user, :port, :roles

    def self.parse(host)
      return host if host.is_a?(Host)

      host = host.to_s.strip
      user, address, port = host.match(PATTERN).captures
      raise ArgumentError, "host cannot be blank" if address.empty?

      new(user: user, port: port, address: address)
    end

    def initialize(address:, port: nil, user: nil, name: nil, roles: nil)
      @user = user.freeze
      @port = (port || 22).to_s.freeze
      @address = address.freeze
      @name = name.freeze
      @roles = Array(roles).map(&:freeze).freeze
      freeze
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
  end
end
