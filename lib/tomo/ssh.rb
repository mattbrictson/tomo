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

    class << self
      def connect(host:, options: {})
        options = Options.new(options) unless options.is_a?(Options)

        Tomo.logger.connect(host)
        return build_dry_run_connection(host, options) if Tomo.dry_run?

        build_connection(host, options)
      end

      private

      def build_dry_run_connection(host, options)
        Connection.dry_run(host, options)
      end

      def build_connection(host, options)
        conn = Connection.new(host, options)
        validator = ConnectionValidator.new(options.executable, conn)
        validator.assert_valid_executable!
        validator.assert_valid_connection!
        validator.dump_env if Tomo.debug?

        conn
      end
    end
  end
end
