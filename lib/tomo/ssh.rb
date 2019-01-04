module Tomo
  module SSH
    autoload :ChildProcess, "tomo/ssh/child_process"
    autoload :Connection, "tomo/ssh/connection"
    autoload :ConnectionValidator, "tomo/ssh/connection_validator"
    autoload :ConnectionError, "tomo/ssh/connection_error"
    autoload :Error, "tomo/ssh/error"
    autoload :ExecutableError, "tomo/ssh/executable_error"
    autoload :Options, "tomo/ssh/options"
    autoload :PermissionError, "tomo/ssh/permission_error"
    autoload :ScriptError, "tomo/ssh/script_error"
    autoload :UnknownError, "tomo/ssh/unknown_error"
    autoload :UnsupportedVersionError, "tomo/ssh/unsupported_version_error"

    def self.connect(host:, options:)
      Tomo.logger.connect(host)

      conn = Connection.new(host, options)
      validator = ConnectionValidator.new(options.executable, conn)
      validator.assert_valid_executable!
      validator.assert_valid_connection!
      validator.dump_env if Tomo.debug?

      conn
    end
  end
end
