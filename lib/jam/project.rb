require "forwardable"

module Jam
  class Project
    extend Forwardable

    autoload :ExecutionPlan, "jam/project/execution_plan"
    autoload :Specification, "jam/project/specification"

    def_delegators :framework, :settings, :tasks

    def initialize(framework, spec)
      @framework = framework
      @deploy_tasks = spec.deploy_tasks
      @host = spec.host
    end

    def build_deploy_plan
      ExecutionPlan.new(framework, host, deploy_tasks)
    end

    def build_run_plan(task_name)
      ExecutionPlan.new(framework, host, [task_name])
    end

    private

    attr_reader :framework, :deploy_tasks, :host
  end
end
