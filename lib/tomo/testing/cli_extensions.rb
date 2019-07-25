module Tomo
  module Testing
    module CLIExtensions
      def exit(status=true)
        raise MockedExitError, status
      end
    end
  end
end
