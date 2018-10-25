require "singleton"

module Jam
  class Framework
    autoload :ChildProcess, "jam/framework/child_process"
    autoload :Current, "jam/framework/current"
    autoload :SSHConnection, "jam/framework/ssh_connection"

    include Singleton

    def initialize
      reset!
    end

    def connect_remote(host)
      conn = SSHConnection.new(host)
      remote = Remote.new(conn)
      current.set(remote: remote) do
        yield(remote)
      end
    ensure
      conn&.close
    end

    def remote
      current[:remote]
    end

    def reset!
      @current = Current.new
    end

    private

    attr_reader :current
  end
end
