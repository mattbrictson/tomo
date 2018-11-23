module Jam
  module SSH
    autoload :Audits, "jam/ssh/audits"
    autoload :ChildProcess, "jam/ssh/child_process"
    autoload :Connection, "jam/ssh/connection"
    autoload :Options, "jam/ssh/options"

    class << self
      def connect(host:, options:)
        Jam.logger.connect(host)

        conn = Connection.new(host, options)
        audits = Audits.new(options.executable, conn)
        audits.assert_valid_executable!
        audits.assert_valid_connection!

        conn
      end
    end
  end
end
