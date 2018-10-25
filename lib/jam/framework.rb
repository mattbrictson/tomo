require "singleton"

module Jam
  class Framework
    autoload :ChildProcess, "jam/framework/child_process"
    autoload :Current, "jam/framework/current"
    autoload :SSHConnection, "jam/framework/ssh_connection"

    def initialize
      reset!
    end

    # TODO: better name for this method?
    def connect_remote(host)
      conn = SSHConnection.new(host)
      remote = Remote.new(conn)
      current.set(remote: remote) do
        yield(remote)
      end
    ensure
      conn&.close
    end

    def current_remote
      current[:remote]
    end

    def reset!
      @current = Current.new
    end

    private

    attr_reader :current
  end
end
