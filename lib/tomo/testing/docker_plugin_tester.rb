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
        super(
          *plugin_names,
          settings: @docker_image.ssh_settings.merge(settings),
          host: host
        )
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
    end
  end
end
