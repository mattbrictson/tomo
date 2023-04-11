module Tomo
  module Testing
    module HostExtensions
      attr_reader :helper_values, :mocks, :scripts, :release

      def initialize(**kwargs)
        @mocks = []
        @scripts = []
        @helper_values = []
        @release = {}
        super
      end

      def mock(script, stdout: "", stderr: "", exit_status: 0)
        mocks << [
          script.is_a?(Regexp) ? script : /\A#{Regexp.quote(script)}\z/,
          Result.new(stdout: stdout, stderr: stderr, exit_status: exit_status)
        ]
      end

      def result_for(script)
        match = mocks.find { |regexp, _| regexp.match?(script.to_s) }
        raise "Scripts cannot be mocked during dry_run" if match && Tomo.dry_run?

        match&.last || Result.empty_success
      end
    end
  end
end
