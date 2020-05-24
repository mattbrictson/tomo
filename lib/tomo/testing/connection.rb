module Tomo
  module Testing
    class Connection < Tomo::SSH::Connection
      def initialize(host, options)
        super(host, options, exec_proc: proc { raise MockedExecError }, child_proc: method(:mock_child_process))
      end

      def ssh_exec(script)
        host.scripts << script
        super
      end

      def ssh_subprocess(script, verbose: false)
        host.scripts << script
        super
      end

      private

      def mock_child_process(*_ssh_args, on_data:)
        result = host.result_for(host.scripts.last)

        on_data.call(result.stdout) unless result.stdout.empty?
        on_data.call(result.stderr) unless result.stderr.empty?
        result
      end
    end
  end
end
