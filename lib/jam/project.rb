require "forwardable"

module Jam
  class Project
    extend Forwardable

    autoload :NotFoundError, "jam/project/not_found_error"
    autoload :Specification, "jam/project/specification"

    def_delegators :framework, :settings, :tasks

    def initialize(framework, spec)
      @framework = framework
      @deploy_tasks = spec.deploy_tasks
      @hosts = spec.hosts
      @roles = spec.roles
    end

    def build_deploy_plan
      Framework::ExecutionPlan.new(framework, hosts, roles, deploy_tasks)
    end

    def build_run_plan(task_name)
      Framework::ExecutionPlan.new(framework, hosts, roles, [task_name])
    end

    private

    attr_reader :framework, :deploy_tasks, :hosts, :roles
  end
end
