# frozen_string_literal: true

module Tomo
  class Runtime
    class InlineThreadPool
      def post(*)
        return if failure?

        yield(*)
        nil
      rescue StandardError => e
        self.failure = e
        nil
      end

      def run_to_completion
        raise failure if failure?
      end

      def failure?
        !!failure
      end

      private

      attr_accessor :failure
    end
  end
end
