module Tomo
  class ConnectionError < RemoteExecutionError
    def to_console
      <<~MESSAGE
        Tomo was unable to use ssh to connect to #{blue(host)}.
      MESSAGE
    end
  end
end
