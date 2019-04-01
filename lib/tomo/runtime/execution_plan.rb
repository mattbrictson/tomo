require "forwardable"

module Tomo
  class Runtime
    class ExecutionPlan
      extend Forwardable

      def initialize(tasks:, hosts:, release: :current,
                     task_filter:, task_runner:)
        @hosts = hosts
        @tasks = tasks
        @task_filter = task_filter
        @task_runner = task_runner
        configure_release(release)
        validate_tasks!
      end

      def applicable_hosts
        tasks_per_host.keys
      end

      def applicable_hosts_sentence
        case applicable_hosts.length
        when 1 then applicable_hosts.first.to_s
        when 2 then applicable_hosts.map(&:to_s).join(" and ")
        else
          "#{applicable_hosts.first} and "\
          "#{applicable_hosts.length - 1} other hosts"
        end
      end

      def execute
        open_connections do |remotes|
          tasks.each do |group|
            remotes.each do |remote|
              filtered = task_filter.filter(Array(group), host: remote.host)
              execute_on_thread_pool(filtered, remote)
            end
            thread_pool.run_to_completion
          end
        end
        self
      end

      private

      def_delegators :@task_runner, :paths
      attr_reader :tasks, :hosts, :release_path, :task_filter, :task_runner

      def configure_release(type)
        case type
        when :current then @release_path = paths.current
        when :new then @release_path = new_release_path
        else raise ArgumentError, "release: must be one of `:current` or `:new`"
        end
      end

      def new_release_path
        start_time = Time.now
        release = start_time.utc.strftime("%Y%m%d%H%M%S")
        paths.releases.join(release)
      end

      def validate_tasks!
        tasks_per_host.values.flatten.uniq.each do |task|
          task_runner.validate_task!(task)
        end
      end

      def tasks_per_host
        @_tasks_per_host ||= begin
          flat_tasks = tasks.flatten
          hosts.each_with_object({}) do |host, hash|
            tasks = task_filter.filter(flat_tasks, host: host)
            hash[host] = tasks unless tasks.empty?
          end
        end
      end

      def open_connections
        remotes = applicable_hosts.each_with_object([]) do |host, opened|
          thread_pool.post(host) do |thr_host|
            opened << task_runner.connect(thr_host)
          end
        end
        thread_pool.run_to_completion
        yield(remotes)
      ensure
        (remotes || []).each(&:close)
      end

      def execute_on_thread_pool(tasks, remote)
        thread_pool.post(tasks, remote) do |thr_tasks, thr_remote|
          thr_tasks.each do |task|
            break if thread_pool.failure?

            Current.with(release_path: release_path) do
              task_runner.run(task: task, remote: thr_remote)
            end
          end
        end
      end

      def thread_pool
        @_thread_pool ||= begin
          if applicable_hosts.length > 1
            ConcurrentRubyThreadPool.new(concurrency)
          else
            InlineThreadPool.new
          end
        end
      end

      def concurrency
        [task_runner.settings[:concurrency].to_i, 1].max
      end
    end
  end
end
