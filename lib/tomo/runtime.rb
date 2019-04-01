require "forwardable"

module Tomo
  class Runtime
    autoload :ConcurrentRubyLoadError, "tomo/runtime/concurrent_ruby_load_error"
    autoload :ConcurrentRubyThreadPool,
             "tomo/runtime/concurrent_ruby_thread_pool"
    autoload :Context, "tomo/runtime/context"
    autoload :Current, "tomo/runtime/current"
    autoload :ExecutionPlan, "tomo/runtime/execution_plan"
    autoload :InlineThreadPool, "tomo/runtime/inline_thread_pool"
    autoload :SettingsRequiredError, "tomo/runtime/settings_required_error"
    autoload :TaskAbortedError, "tomo/runtime/task_aborted_error"
    autoload :TaskRunner, "tomo/runtime/task_runner"

    extend Forwardable
    def_delegators :@task_runner, :settings, :paths, :tasks

    def initialize(deploy_tasks:, hosts:, task_filter:, task_runner:)
      @deploy_tasks = deploy_tasks.freeze
      @hosts = hosts.freeze
      @task_filter = task_filter
      @task_runner = task_runner
      freeze
    end

    def deploy!
      execution_plan_for(deploy_tasks, release: :new).execute
    end

    def run!(task)
      execution_plan_for([task], release: :current).execute
    end

    def execution_plan_for(tasks, release: :current)
      ExecutionPlan.new(
        tasks: tasks,
        hosts: hosts,
        release: release,
        task_filter: task_filter,
        task_runner: task_runner
      )
    end

    attr_reader :deploy_tasks, :hosts, :task_filter, :task_runner
  end
end
