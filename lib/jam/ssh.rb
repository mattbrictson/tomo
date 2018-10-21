module Jam
  module SSH
    autoload :ChildProcess, "jam/ssh/child_process"
    autoload :Connection, "jam/ssh/connection"

    def self.connect(host, &block)
      connection = Jam::SSH::Connection.new(host)
      yield(connection)
    ensure
      connection&.close
    end
  end
end
