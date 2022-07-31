require "time"

module Tomo
  class Runtime
    autoload :ConcurrentRubyLoadError, "tomo/runtime/concurrent_ruby_load_error"
    autoload :ConcurrentRubyThreadPool, "tomo/runtime/concurrent_ruby_thread_pool"
    autoload :Context, "tomo/runtime/context"
    autoload :Current, "tomo/runtime/current"
    autoload :ExecutionPlan, "tomo/runtime/execution_plan"
    autoload :Explanation, "tomo/runtime/explanation"
    autoload :HostExecutionStep, "tomo/runtime/host_execution_step"
    autoload :InlineThreadPool, "tomo/runtime/inline_thread_pool"
    autoload :NoTasksError, "tomo/runtime/no_tasks_error"
    autoload :PrivilegedTask, "tomo/runtime/privileged_task"
    autoload :SettingsInterpolation, "tomo/runtime/settings_interpolation"
    autoload :SettingsRequiredError, "tomo/runtime/settings_required_error"
    autoload :TaskAbortedError, "tomo/runtime/task_aborted_error"
    autoload :TaskRunner, "tomo/runtime/task_runner"
    autoload :TemplateNotFoundError, "tomo/runtime/template_not_found_error"
    autoload :UnknownTaskError, "tomo/runtime/unknown_task_error"

    def self.local_user
      ENV["USER"] || ENV["USERNAME"] || `whoami`.chomp
    rescue StandardError
      nil
    end

    attr_reader :tasks

    def initialize(deploy_tasks:, setup_tasks:, hosts:, task_filter:, settings:, plugins_registry:)
      @deploy_tasks = deploy_tasks.freeze
      @setup_tasks = setup_tasks.freeze
      @hosts = hosts.freeze
      @task_filter = task_filter.freeze
      @settings = settings
      @plugins_registry = plugins_registry
      @tasks = plugins_registry.task_names
      freeze
    end

    def deploy!
      NoTasksError.raise_with(task_type: "deploy") if deploy_tasks.empty?

      execution_plan_for(deploy_tasks, release: :new).execute
    end

    def setup!
      NoTasksError.raise_with(task_type: "setup") if setup_tasks.empty?

      execution_plan_for(setup_tasks, release: :tmp).execute
    end

    def run!(task, *args, privileged: false)
      task = task.dup.extend(PrivilegedTask) if privileged
      execution_plan_for([task], release: :current, args: args).execute
    end

    def execution_plan_for(tasks, release: :current, args: [])
      ExecutionPlan.new(
        tasks: tasks,
        hosts: hosts,
        task_filter: task_filter,
        task_runner: new_task_runner(release, args)
      )
    end

    private

    attr_reader :deploy_tasks, :setup_tasks, :hosts, :task_filter, :settings, :plugins_registry

    def new_task_runner(release_type, args)
      run_settings = { release_path: release_path_for(release_type) }
        .merge(local_user: Runtime.local_user)
        .merge(settings)
        .merge(run_args: args)

      TaskRunner.new(plugins_registry: plugins_registry, settings: run_settings)
    end

    def release_path_for(type)
      start_time = Time.now
      release = start_time.utc.strftime("%Y%m%d%H%M%S")

      case type
      when :current then "%{current_path}"
      when :new then "%{releases_path}/#{release}"
      when :tmp then "%{tmp_path}/#{release}"
      else
        raise ArgumentError, "release: must be :current, :new, or :tmp"
      end
    end
  end
end
