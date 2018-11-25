module Jam
  module SSH
    autoload :Audits, "jam/ssh/audits"
    autoload :ChildProcess, "jam/ssh/child_process"
    autoload :Connection, "jam/ssh/connection"
    autoload :ConnectionError, "jam/ssh/connection_error"
    autoload :Error, "jam/ssh/error"
    autoload :ExecutableError, "jam/ssh/executable_error"
    autoload :Options, "jam/ssh/options"
    autoload :PermissionError, "jam/ssh/permission_error"
    autoload :ScriptError, "jam/ssh/script_error"
    autoload :UnknownError, "jam/ssh/unknown_error"
    autoload :UnsupportedVersionError, "jam/ssh/unsupported_version_error"

    class << self
      # TODO: move to Jam.debug
      attr_writer :debug

      def debug?
        !!@debug
      end

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
