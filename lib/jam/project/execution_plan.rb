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
        framework.connect(host) do
          task_names.each { |task| framework.invoke_task(task) }
        end
      end

      private

      attr_reader :framework, :task_names
    end
  end
end
