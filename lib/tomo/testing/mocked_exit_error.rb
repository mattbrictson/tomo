module Tomo
  module Testing
    class MockedExitError < Exception # rubocop:disable Lint/InheritException
      attr_reader :status

      def initialize(status)
        @status = status
        super("tomo exited with status #{status}")
      end

      def success?
        status == true || status == 0
      end
    end
  end
end
