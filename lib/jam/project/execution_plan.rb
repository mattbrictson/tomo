module Jam
  class Project
    class ExecutionPlan
      attr_reader :host

      def initialize(framework, host, task_names)
        @framework = framework
        @host = host
        @task_names = task_names
      end

      def call
        Jam.logger.prefix_host(host, "1")
        framework.connect(host) do |remote|
          framework.execute(tasks: task_names, remote: remote)
        end
      end

      private

      attr_reader :framework, :task_names
    end
  end
end
