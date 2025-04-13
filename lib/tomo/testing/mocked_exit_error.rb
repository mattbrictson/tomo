# frozen_string_literal: true

module Tomo
  module Testing
    class MockedExitError < Exception # rubocop:disable Lint/InheritException
      attr_reader :status

      def initialize(status)
        @status = status
        super("tomo exited with status #{status}")
      end

      def success?
        [true, 0].include?(status)
      end
    end
  end
end
