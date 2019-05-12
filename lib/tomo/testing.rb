require "tomo"

module Tomo
  module Testing
    autoload :Connection, "tomo/testing/connection"
    autoload :HostExtensions, "tomo/testing/host_extensions"
    autoload :MockedExecError, "tomo/testing/mocked_exec_error"
    autoload :PluginTester, "tomo/testing/plugin_tester"
    autoload :SSHExtensions, "tomo/testing/ssh_extensions"
  end
end

Tomo.logger = Tomo::Logger.new(
  stdout: File.open(File::NULL, "w"), stderr: File.open(File::NULL, "w")
)
Tomo::Colors.disable
Tomo::Host.prepend Tomo::Testing::HostExtensions
class << Tomo::SSH
  prepend Tomo::Testing::SSHExtensions
end
