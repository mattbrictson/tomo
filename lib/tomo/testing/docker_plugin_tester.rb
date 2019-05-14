require "fileutils"
require "securerandom"
require "tmpdir"

module Tomo
  module Testing
    class DockerPluginTester < PluginTester
      def initialize(*plugin_names, settings: {}, setup_script: nil)
        @docker_image = DockerImage.new
        @docker_image.setup_script = setup_script if setup_script
        @docker_image.build_and_run
        host = @docker_image.host
        super(*plugin_names, settings: ssh_settings.merge(settings), host: host)
      end

      def run(shell_script, **kwargs)
        call_helper(:run, shell_script, **kwargs)
      end

      def run_task(task, *args)
        Testing.enabling_ssh do
          super
        end
      end

      def teardown
        docker_image.stop
      end

      private

      attr_reader :docker_image

      # Connecting to SSH servers on local docker containers often triggers
      # known_hosts errors due to each container potentially having a
      # different host key. Work around this by using an empty blank temp file
      # for storing known_hosts.
      def ssh_settings
        hosts_file = File.join(Dir.tmpdir, "tomo_#{SecureRandom.hex(8)}_hosts")
        key_file = File.expand_path("tomo_test_ed25519", __dir__)
        FileUtils.chmod(0o600, key_file)

        {
          ssh_extra_opts: [
            "-o", "UserKnownHostsFile=#{hosts_file}",
            "-o", "IdentityFile=#{key_file}"
          ],
          ssh_strict_host_key_checking: false
        }
      end
    end
  end
end
