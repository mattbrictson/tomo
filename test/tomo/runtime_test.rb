require "test_helper"

class Tomo::RuntimeTest < Minitest::Test
  def test_deploy_raises_if_no_deploy_tasks
    runtime = Tomo::Configuration.new.build_runtime
    assert_raises(Tomo::Runtime::NoTasksError) do
      runtime.deploy!
    end
  end

  def test_setup_raises_if_no_setup_tasks
    runtime = Tomo::Configuration.new.build_runtime
    assert_raises(Tomo::Runtime::NoTasksError) do
      runtime.setup!
    end
  end

  def test_execution_plan_for_raises_if_tasks_is_empty
    runtime = Tomo::Configuration.new.build_runtime
    assert_raises(ArgumentError) do
      runtime.execution_plan_for([])
    end
  end
end
