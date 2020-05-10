module Tomo
  module Testing
    class MockPluginTester
      include LogCapturing

      def initialize(*plugin_names, settings: {}, release: {})
        @host = Host.parse("testing@host")
        @host.release.merge!(release)
        config = Configuration.new
        config.hosts << @host
        config.plugins.push(*plugin_names, "testing")
        config.settings[:application] = "testing"
        config.settings.merge!(settings)
        @runtime = config.build_runtime
      end

      def call_helper(helper, *args, **kwargs)
        run_task("testing:call_helper", helper, args, kwargs)
        host.helper_values.pop
      end

      def run_task(task, *args)
        capturing_logger_output do
          runtime.run!(task, *args, privileged: false)
          nil
        end
      end

      def executed_script
        return executed_scripts.first unless executed_scripts.length > 1

        raise "Expected one executed script, got multiple: #{executed_scripts}"
      end

      def executed_scripts
        host.scripts.map(&:to_s)
      end

      def mock_script_result(script=/.*/, **kwargs)
        host.mock(script, **kwargs)
        self
      end

      private

      attr_reader :host, :runtime
    end
  end
end
