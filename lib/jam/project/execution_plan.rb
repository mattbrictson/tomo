module Jam
  class Project
    class ExecutionPlan
      attr_reader :hosts

      def initialize(framework, hosts, task_names)
        @framework = framework
        @hosts = hosts
        @task_names = task_names
      end

      def call
        remotes = hosts.map { |host| framework.connect(host) }
        remotes.each do |remote|
          framework.execute(tasks: task_names, remote: remote)
        end
      end

      def hosts_sentence
        case hosts.length
        when 1 then hosts.first.to_s
        when 2 then hosts.map(&:to_s).join(" and ")
        else
          "#{hosts.first} and #{hosts.length - 1} other hosts"
        end
      end

      private

      attr_reader :framework, :task_names
    end
  end
end
