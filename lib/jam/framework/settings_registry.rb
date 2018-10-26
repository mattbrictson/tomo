module Jam
  class Framework
    class SettingsRegistry
      def initialize
        @settings = {}
      end

      def define(definitions)
        @settings.merge!(definitions) { |_, existing, _| existing }
      end

      def assign(assignments)
        @settings.merge!(assignments)
      end

      def to_hash
        @settings.dup
      end

      private

      attr_reader :settings
    end
  end
end
