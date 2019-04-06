module Tomo
  class Configuration
    class Environment
      attr_accessor :hosts, :settings

      def initialize
        @hosts = []
        @settings = {}
      end
    end
  end
end
