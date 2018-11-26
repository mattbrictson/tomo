module Jam
  module SSH
    autoload :ChildProcess, "jam/ssh/child_process"
    autoload :Connection, "jam/ssh/connection"
    autoload :ConnectionValidator, "jam/ssh/connection_validator"
    autoload :ConnectionError, "jam/ssh/connection_error"
    autoload :Error, "jam/ssh/error"
    autoload :ExecutableError, "jam/ssh/executable_error"
    autoload :Options, "jam/ssh/options"
    autoload :PermissionError, "jam/ssh/permission_error"
    autoload :ScriptError, "jam/ssh/script_error"
    autoload :UnknownError, "jam/ssh/unknown_error"
    autoload :UnsupportedVersionError, "jam/ssh/unsupported_version_error"

    def self.connect(host:, options:)
      Jam.logger.connect(host)

      conn = Connection.new(host, options)
      validator = ConnectionValidator.new(options.executable, conn)
      validator.assert_valid_executable!
      validator.assert_valid_connection!
      validator.dump_env if Jam.debug?

      conn
    end
  end
end
