module Tomo
  class Runtime
    class HostExecutionStep
      attr_reader :applicable_hosts, :applicable_tasks

      def initialize(tasks:, host:, task_filter:, task_runner:)
        tasks = Array(tasks).flatten
        @host = host
        @task_runner = task_runner
        @applicable_tasks = task_filter.filter(tasks, host: @host).freeze
        @applicable_hosts = compute_applicable_hosts
        freeze
      end

      def empty?
        applicable_tasks.empty?
      end

      def execute(thread_pool:, remotes:)
        return if applicable_tasks.empty?

        thread_pool.post do
          applicable_tasks.each do |task|
            break if thread_pool.failure?

            task_host = task.is_a?(PrivilegedTask) ? host.as_privileged : host
            remote = remotes[task_host]
            task_runner.run(task: task, remote: remote)
          end
        end
      end

      def explain
        desc = []
        applicable_tasks.each do |task|
          task_host = task.is_a?(PrivilegedTask) ? host.as_privileged : host
          desc << "RUN #{task} ON #{task_host}"
        end
        desc.join("\n")
      end

      private

      attr_reader :host, :task_runner

      def compute_applicable_hosts
        priv_tasks, normal_tasks = applicable_tasks.partition do |task|
          task.is_a?(PrivilegedTask)
        end

        hosts = []
        hosts << host if normal_tasks.any?
        hosts << host.as_privileged if priv_tasks.any?
        hosts.uniq.freeze
      end
    end
  end
end
