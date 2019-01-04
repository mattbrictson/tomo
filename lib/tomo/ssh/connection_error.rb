module Tomo
  module SSH
    class ConnectionError < Error
      def to_console
        msg = <<~ERROR
          Unable to connect via SSH to #{yellow(host.address)} on port #{yellow(host.port)}.

          Make sure the hostname and port are correct and that you have the
          necessary network (or VPN) access.
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
