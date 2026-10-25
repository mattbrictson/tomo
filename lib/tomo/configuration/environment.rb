# frozen_string_literal: true

module Tomo
  class Configuration
    class Environment
      attr_accessor :hosts, :settings

      def initialize(default: false)
        @default = default
        @hosts = []
        @settings = {}
      end

      def default?
        !!@default
      end
    end
  end
end
