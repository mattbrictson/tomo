require "time"

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
    autoload :UnknownTaskError, "tomo/runtime/unknown_task_error"

    attr_reader :tasks

    # rubocop:disable Metrics/ParameterLists
    def initialize(deploy_tasks:, hosts:, helper_modules:, task_filter:,
                   settings_registry:, tasks_registry:)
      @deploy_tasks = deploy_tasks.freeze
      @hosts = hosts.freeze
      @helper_modules = helper_modules.freeze
      @task_filter = task_filter.freeze
      @settings_registry = settings_registry
      @tasks_registry = tasks_registry
      @tasks = tasks_registry.task_names
      freeze
    end
    # rubocop:enable Metrics/ParameterLists

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
        task_filter: task_filter,
        task_runner: new_task_runner(release)
      )
    end

    private

    attr_reader :deploy_tasks, :hosts, :helper_modules, :task_filter,
                :settings_registry, :tasks_registry

    def new_task_runner(release_type)
      settings_registry.assign_settings(
        release_path: release_path_for(release_type)
      )
      TaskRunner.new(
        helper_modules: helper_modules,
        settings: settings_registry.to_hash,
        tasks_registry: tasks_registry
      )
    end

    def release_path_for(type)
      case type
      when :current
        "%<current_path>"
      when :new
        start_time = Time.now
        release = start_time.utc.strftime("%Y%m%d%H%M%S")
        "%<releases_path>/#{release}"
      else
        raise ArgumentError, "release: must be one of `:current` or `:new`"
      end
    end
  end
end
