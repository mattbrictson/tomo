module Tomo
  class Configuration
    class Glob
      def initialize(spec)
        @spec = spec.to_s.freeze
        regexp_parts = @spec.split(/(\*)/).map do |part|
          part == "*" ? ".*" : Regexp.quote(part)
        end
        @pattern = Regexp.new(regexp_parts.join).freeze
        freeze
      end

      def match?(str)
        pattern.match?(str)
      end

      def to_s
        spec
      end

      private

      attr_reader :pattern, :spec
    end
  end
end
