require "forwardable"

module Tomo
  class Project
    extend Forwardable

    autoload :NotFoundError, "tomo/project/not_found_error"
    autoload :Specification, "tomo/project/specification"
    autoload :UnknownEnvironmentError, "tomo/project/unknown_environment_error"
    autoload :UnspecifiedEnvironmentError,
             "tomo/project/unspecified_environment_error"

    def_delegators :framework, :settings, :tasks

    def initialize(framework, spec)
      @framework = framework
      @deploy_tasks = spec.deploy_tasks
      @hosts = spec.hosts
      @roles = spec.roles
    end

    def build_deploy_plan
      new_execution_plan(deploy_tasks)
    end

    def build_run_plan(task_name)
      new_execution_plan([task_name])
    end

    private

    attr_reader :framework, :deploy_tasks, :hosts, :roles

    def new_execution_plan(tasks)
      Framework::ExecutionPlan.new(
        framework: framework,
        hosts: hosts,
        roles: roles,
        tasks: tasks
      )
    end
  end
end
