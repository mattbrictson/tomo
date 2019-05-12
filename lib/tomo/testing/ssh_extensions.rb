module Tomo
  module Testing
    module SSHExtensions
      private

      def build_connection(host, options)
        Testing::Connection.new(host, options)
      end
    end
  end
end
