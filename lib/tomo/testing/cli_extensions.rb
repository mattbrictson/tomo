module Tomo
  module Testing
    module CLIExtensions
      def exit(status=true) # rubocop:disable Style/OptionalBooleanParameter
        raise MockedExitError, status
      end
    end
  end
end
