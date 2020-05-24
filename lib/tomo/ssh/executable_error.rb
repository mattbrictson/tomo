module Tomo
  module SSH
    class ExecutableError < Error
      attr_accessor :executable

      def to_console
        hint = if executable.to_s.include?("/")
                 "Is the ssh binary properly installed in this location?"
               else
                 "Is #{yellow(executable)} installed and in your #{blue('$PATH')}?"
               end

        <<~ERROR
          Failed to execute #{yellow(executable)}.
          #{hint}
        ERROR
      end
    end
  end
end
