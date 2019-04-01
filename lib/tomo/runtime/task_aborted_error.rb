module Tomo
  class Runtime
    class TaskAbortedError < Tomo::Error
      attr_accessor :task, :host

      def to_console
        <<~ERROR
          The #{yellow(task)} task failed on #{yellow(host)}.

          #{red(message)}
        ERROR
      end
    end
  end
end
