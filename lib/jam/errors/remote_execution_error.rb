module Jam
  class RemoteExecutionError < Error
    attr_accessor :host, :script, :ssh_command, :result
  end
end
