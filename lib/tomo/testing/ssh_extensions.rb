module Tomo
  module Testing
    module SSHExtensions
      private

      def build_dry_run_connection(host, options)
        return super if Testing.ssh_enabled

        Testing::Connection.new(host, options)
      end

      def build_connection(host, options)
        return super if Testing.ssh_enabled

        Testing::Connection.new(host, options)
      end
    end
  end
end
