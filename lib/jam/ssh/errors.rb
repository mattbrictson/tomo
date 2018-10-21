module Jam
  module SSH
    Error = Class.new(Jam::Error)

    class RemoteExecutionError < Error
      attr_accessor :host, :remote_command, :ssh_command, :result
    end
  end
end
