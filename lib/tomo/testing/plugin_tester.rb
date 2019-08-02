module Tomo
  module Testing
    class PluginTester
      include LogCapturing

      def initialize(*plugin_names, settings: {}, host:)
        @host = host
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

      def settings
        runtime.execution_plan_for([]).settings
      end

      private

      attr_reader :host, :runtime
    end
  end
end
