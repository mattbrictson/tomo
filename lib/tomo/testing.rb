require "tomo"

module Tomo
  module Testing
    autoload :CLIExtensions, "tomo/testing/cli_extensions"
    autoload :CLITester, "tomo/testing/cli_tester"
    autoload :Connection, "tomo/testing/connection"
    autoload :DockerImage, "tomo/testing/docker_image"
    autoload :HostExtensions, "tomo/testing/host_extensions"
    autoload :Local, "tomo/testing/local"
    autoload :LogCapturing, "tomo/testing/log_capturing"
    autoload :MockedExecError, "tomo/testing/mocked_exec_error"
    autoload :MockedExitError, "tomo/testing/mocked_exit_error"
    autoload :MockPluginTester, "tomo/testing/mock_plugin_tester"
    autoload :RemoteExtensions, "tomo/testing/remote_extensions"
    autoload :SSHExtensions, "tomo/testing/ssh_extensions"

    class << self
      attr_reader :ssh_enabled

      def enabling_ssh
        orig_ssh = ssh_enabled
        @ssh_enabled = true
        yield
      ensure
        @ssh_enabled = orig_ssh
      end
    end
    @ssh_enabled = false
  end
end

Tomo.logger = Tomo::Logger.new(
  stdout: File.open(File::NULL, "w"), stderr: File.open(File::NULL, "w")
)
class << Tomo::CLI
  prepend Tomo::Testing::CLIExtensions
end
Tomo::Colors.enabled = false
Tomo::Host.prepend Tomo::Testing::HostExtensions
Tomo::Remote.prepend Tomo::Testing::RemoteExtensions
class << Tomo::SSH
  prepend Tomo::Testing::SSHExtensions
end
