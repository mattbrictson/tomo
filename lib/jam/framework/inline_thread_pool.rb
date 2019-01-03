module Jam
  class Framework
    class InlineThreadPool
      def post(*args)
        return if failure?

        yield(*args)
        nil
      rescue StandardError => error
        self.failure = error
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
