module Tomo
  module SSH
    class PermissionError < Error
      def to_console
        as_user = host.user && " as user #{yellow(host.user)}"

        msg = <<~ERROR
          Unable to connect via SSH to #{yellow(host.address)}#{as_user}.

          Check that you’ve specified the correct username and that your public key
          is properly installed on the server.
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
