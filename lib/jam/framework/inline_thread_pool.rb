module Jam
  class Framework
    class InlineThreadPool
      attr_writer :failure

      def post(*args)
        return if failure?

        yield(*args)
        nil
      end

      def run_to_completion
        raise @failure if failure?
      end

      def failure?
        !!@failure
      end
    end
  end
end
