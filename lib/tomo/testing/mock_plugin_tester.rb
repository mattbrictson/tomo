module Tomo
  module Testing
    class MockPluginTester < PluginTester
      def initialize(*plugin_names, settings: {})
        host = Host.parse("testing@host")
        super(*plugin_names, settings: settings, host: host)
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
    end
  end
end
