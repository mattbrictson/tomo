require "fileutils"
require "open3"
require "securerandom"
require "shellwords"
require "tmpdir"

at_exit { Tomo::Testing::DockerImage.running_images.each(&:stop) }

module Tomo
  module Testing
    class DockerImage
      class << self
        attr_reader :running_images
      end
      @running_images = []

      attr_accessor :setup_script
      attr_reader :host

      def initialize
        @setup_script = "#!/bin/bash\n"
      end

      def build_and_run
        raise "Already running!" if frozen?

        set_up_build_dir
        pull_base_image_if_needed
        @image_id = build_image
        @container_id = start_container
        @host = Host.parse("deployer@localhost:#{find_ssh_port}")
        DockerImage.running_images << self
        freeze
      end

      def stop
        DockerImage.running_images.delete(self)
        run!("docker stop #{container_id}", raise_on_error: false)
      end

      private

      attr_reader :container_id, :image_id

      def pull_base_image_if_needed
        images = run!('docker images --format "{{.ID}}" ubuntu:18.04')
        run!("docker pull ubuntu:18.04") if images.strip.empty?
      end

      def build_image
        run!("docker build #{build_dir}")[/Successfully built (\S+)$/i, 1]
      end

      def start_container
        host_container = ENV["_TOMO_CONTAINER"]
        args = "--detach --init #{image_id}"
        if host_container
          args.prepend("--network=container:#{host_container} ")
        else
          args.prepend("--publish-all ")
        end
        run!("docker run #{args}")[/\S+/]
      end

      def find_ssh_port
        return 22 if ENV["_TOMO_CONTAINER"]

        run!("docker port #{container_id} 22")[/:(\d+)/, 1].to_i
      end

      def set_up_build_dir
        FileUtils.mkdir_p(build_dir)
        files = %w[Dockerfile tomo_test_ed25519.pub ubuntu_setup.sh]
        files.each do |file|
          FileUtils.cp(File.expand_path(file, __dir__), build_dir)
        end
        IO.write(File.join(build_dir, "custom_setup.sh"), setup_script)
        FileUtils.chmod(0o755, File.join(build_dir, "custom_setup.sh"))
      end

      def run!(command, raise_on_error: true)
        output, status = Open3.capture2e(command)
        if raise_on_error && !status.success?
          raise "Command failed: #{command}\n#{output}"
        end

        output
      end

      def build_dir
        @_build_dir ||= begin
          File.join(Dir.tmpdir, "tomo_docker_#{SecureRandom.hex(8)}")
        end
      end
    end
  end
end
