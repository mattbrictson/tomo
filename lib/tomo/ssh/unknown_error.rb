module Tomo
  module SSH
    class UnknownError < Error
      def to_console
        msg = <<~ERROR
          An unknown error occurred trying to SSH to #{yellow(host)}.
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
