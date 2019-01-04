module Tomo
  module SSH
    class UnsupportedVersionError < Error
      attr_accessor :command, :expected_version

      def to_console
        msg = <<~ERROR
          Expected #{yellow(command)} to return #{blue(expected_version)} or higher.
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
