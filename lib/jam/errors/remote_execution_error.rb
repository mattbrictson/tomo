module Jam
  class RemoteExecutionError < Error
    attr_accessor :host, :script, :ssh_command, :result

    def to_console
      <<~MESSAGE
        The command failed to run #{blue(host)}.
      MESSAGE
    end
  end
end
