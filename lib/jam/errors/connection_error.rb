module Jam
  class ConnectionError < RemoteExecutionError
    def to_console
      <<~MESSAGE
        Jam was unable to use ssh to connect to #{blue(host)}.
      MESSAGE
    end
  end
end
