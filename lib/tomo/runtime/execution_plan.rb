require "forwardable"

module Tomo
  class Runtime
    class ExecutionPlan
      extend Forwardable

      def_delegators :@task_runner, :paths, :settings

      attr_reader :applicable_hosts

      def initialize(tasks:, hosts:, task_filter:, task_runner:)
        @hosts = hosts
        @task_runner = task_runner
        @plan = build_plan(tasks, task_filter)
        @applicable_hosts = gather_applicable_hosts
        @thread_pool = build_thread_pool
        freeze
        validate_tasks!
      end

      def applicable_hosts_sentence
        return "no hosts" if applicable_hosts.empty?

        case applicable_hosts.length
        when 1 then applicable_hosts.first.to_s
        when 2 then applicable_hosts.map(&:to_s).join(" and ")
        else
          "#{applicable_hosts.first} and #{applicable_hosts.length - 1} other hosts"
        end
      end

      def execute
        Tomo.logger.debug("Execution plan:\n#{explain}")
        open_connections do |remotes|
          plan.each do |steps|
            steps.each do |step|
              step.execute(thread_pool: thread_pool, remotes: remotes)
            end
            thread_pool.run_to_completion
          end
        end
        self
      end

      def explain
        Explanation.new(applicable_hosts, plan, concurrency).to_s
      end

      private

      attr_reader :hosts, :plan, :task_runner, :thread_pool

      def validate_tasks!
        plan.each do |steps|
          steps.each do |step|
            step.applicable_tasks.each do |task|
              task_runner.validate_task!(task)
            end
          end
        end
      end

      def open_connections
        remotes = applicable_hosts.each_with_object({}) do |host, opened|
          thread_pool.post(host) do |thr_host|
            opened[thr_host] = task_runner.connect(thr_host)
          end
        end
        thread_pool.run_to_completion
        yield(remotes)
      ensure
        (remotes || {}).each_value(&:close)
      end

      def build_plan(tasks, task_filter)
        tasks.each_with_object([]) do |task, result|
          steps = hosts.map do |host|
            HostExecutionStep.new(tasks: task, host: host, task_filter: task_filter, task_runner: task_runner)
          end
          steps.reject!(&:empty?)
          result << steps unless steps.empty?
        end
      end

      def gather_applicable_hosts
        plan.each_with_object([]) do |steps, result|
          steps.each do |step|
            result.push(*step.applicable_hosts)
          end
        end.uniq
      end

      def build_thread_pool
        if plan.map(&:length).max.to_i > 1
          ConcurrentRubyThreadPool.new(concurrency)
        else
          InlineThreadPool.new
        end
      end

      def concurrency
        [settings[:concurrency].to_i, 1].max
      end
    end
  end
end
