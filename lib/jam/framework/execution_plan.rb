module Jam
  class Framework
    class ExecutionPlan
      def initialize(framework, hosts, roles, tasks)
        @framework = framework
        @hosts = hosts
        @roles = roles
        @tasks = tasks
      end

      def applicable_hosts
        @_applicable_hosts ||= begin
          flat_tasks = tasks.flatten
          hosts.reject do |host|
            roles.filter_tasks(flat_tasks, roles: host.roles).empty?
          end
        end
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

      def run
        open_connections do |remotes|
          tasks.each do |group|
            remotes.each do |remote|
              host = remote.host
              filtered = roles.filter_tasks(Array(group), roles: host.roles)
              execute_on_thread_pool(filtered, remote)
            end
            thread_pool.run_to_completion
          end
        end
      end

      private

      attr_reader :framework, :hosts, :roles, :tasks

      def open_connections
        remotes = applicable_hosts.each_with_object([]) do |host, opened|
          thread_pool.post(host) do |thr_host|
            opened << framework.connect(thr_host)
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

            framework.execute(task: task, remote: thr_remote)
          end
        end
      end

      def thread_pool
        @_thread_pool ||= if applicable_hosts.length > 1
                            ConcurrentRubyThreadPool.new(concurrency)
                          else
                            InlineThreadPool.new
                          end
      end

      def concurrency
        [framework.settings[:concurrency].to_i, 1].max
      end
    end
  end
end
