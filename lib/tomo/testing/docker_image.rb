require "fileutils"
require "open3"
require "securerandom"
require "shellwords"
require "tmpdir"

at_exit { Tomo::Testing::DockerImage.running_images.each(&:stop) }

module Tomo
  module Testing
    class DockerImage
      FILES_TO_COPY = %w[
        Dockerfile
        systemctl.rb
        tomo_test_ed25519.pub
        ubuntu_setup.sh
      ].freeze
      private_constant :FILES_TO_COPY

      class << self
        attr_reader :running_images
      end
      @running_images = []

      attr_reader :host

      def build_and_run
        raise "Already running!" if frozen?

        set_up_build_dir
        pull_base_image_if_needed
        set_up_private_key
        @image_id = build_image
        @container_id = start_container
        @host = Host.parse("deployer@localhost", port: find_ssh_port)
        DockerImage.running_images << self
        freeze
      end

      def stop
        DockerImage.running_images.delete(self)
        Local.capture("docker stop #{container_id}", raise_on_error: false)
        nil
      end

      def puma_port
        Local.capture("docker port #{container_id} 3000")[/:(\d+)/, 1].to_i
      end

      # Connecting to SSH servers on local docker containers often triggers
      # known_hosts errors due to each container potentially having a
      # different host key. Work around this by using an empty blank temp file
      # for storing known_hosts.
      def ssh_settings
        hosts_file = File.join(Dir.tmpdir, "tomo_#{SecureRandom.hex(8)}_hosts")
        {
          ssh_extra_opts: [
            "-o",
            "UserKnownHostsFile=#{hosts_file}",
            "-o",
            "IdentityFile=#{private_key_path}"
          ],
          ssh_strict_host_key_checking: false
        }
      end

      private

      attr_reader :container_id, :image_id, :private_key_path

      def pull_base_image_if_needed
        images = Local.capture('docker images --format "{{.ID}}" ubuntu:22.04')
        Local.capture("docker pull ubuntu:22.04") if images.strip.empty?
      end

      def set_up_private_key
        @private_key_path = File.join(Dir.tmpdir, "tomo_test_ed25519_#{SecureRandom.hex(8)}")
        FileUtils.cp(File.expand_path("tomo_test_ed25519", __dir__), private_key_path)
        FileUtils.chmod(0o600, private_key_path)
      end

      def build_image
        tag = "tomo_testing:latest"
        Local.capture("docker build --tag #{tag} #{build_dir}")
        tag
      end

      def start_container
        args = "--publish-all --detach --init #{image_id}"
        Local.capture("docker run #{args}")[/\S+/].tap do
          # Allow some time for the container to finish booting
          sleep 0.1
        end
      end

      def find_ssh_port
        Local.capture("docker port #{container_id} 22")[/:(\d+)/, 1].to_i
      end

      def set_up_build_dir
        FileUtils.mkdir_p(build_dir)
        FILES_TO_COPY.each do |file|
          FileUtils.cp(File.expand_path(file, __dir__), build_dir)
        end
      end

      def build_dir
        @_build_dir ||= File.join(Dir.tmpdir, "tomo_docker_#{SecureRandom.hex(8)}")
      end
    end
  end
end
