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

            task_host = task.is_a?(PriviligedTask) ? host.as_priviliged : host
            remote = remotes[task_host]
            task_runner.run(task: task, remote: remote)
          end
        end
      end

      private

      attr_reader :host, :task_runner

      def compute_applicable_hosts
        priv_tasks, normal_tasks = applicable_tasks.partition do |task|
          task.is_a?(PriviligedTask)
        end

        hosts = []
        hosts << host if normal_tasks.any?
        hosts << host.as_priviliged if priv_tasks.any?
        hosts.uniq.freeze
      end
    end
  end
end
