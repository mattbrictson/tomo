module Tomo
  module Testing
    class MockedExitError < Exception # rubocop:disable Lint/InheritException
      attr_reader :status

      def initialize(status)
        @status = status
        super("tomo exited with status #{status}")
      end

      def success?
        status == true || status == 0 # rubocop:disable Style/NumericPredicate
      end
    end
  end
end
