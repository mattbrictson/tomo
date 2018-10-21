module Jam
  module SSH
    autoload :ChildProcess, "jam/ssh/child_process"
    autoload :Connection, "jam/ssh/connection"
    autoload :Result, "jam/ssh/result"

    def self.connect(host, &block)
      connection = Connection.new(host)
      yield(connection)
    ensure
      connection&.close
    end
  end
end
