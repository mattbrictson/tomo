module Tomo
  module Testing
    module RemoteExtensions
      def initialize(*args)
        super
        release.merge!(ssh.host.release)
      end
    end
  end
end
