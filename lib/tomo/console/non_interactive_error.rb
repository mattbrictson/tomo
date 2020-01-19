module Tomo
  class Console
    class NonInteractiveError < Tomo::Error
      attr_accessor :task, :ci_var

      def to_console
        error = ""
        error << "#{operation_name} requires an interactive console."
        error << "\n\n#{seems_like_ci}" if ci_var
        error
      end

      private

      def seems_like_ci
        <<~ERROR
          This appears to be a non-interactive CI environment because the
          #{yellow(ci_var)} environment variable is set.
        ERROR
      end

      def operation_name
        task ? "The #{yellow(task)} task" : "Tomo::Console"
      end
    end
  end
end
