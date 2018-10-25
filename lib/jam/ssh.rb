# TODO: remove
module Jam
  module SSH
    def self.connect(host)
      connection = Jam::Framework::SSHConnection.new(host)
      yield(connection)
    ensure
      connection&.close
    end
  end
end
