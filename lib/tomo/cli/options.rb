module Tomo
  class CLI
    class Options
      def initialize
        @options = {}
      end

      def any?
        options.any?
      end

      def key?(key)
        !all(key).empty?
      end

      def fetch(key, default)
        values = all(key)
        values.empty? ? default : values.first
      end

      def [](key)
        fetch(key, nil)
      end

      def []=(key, value)
        all(key).clear.push(value)
      end

      def all(key)
        options[key] ||= []
      end

      private

      attr_reader :options
    end
  end
end
