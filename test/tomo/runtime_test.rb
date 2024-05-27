# frozen_string_literal: true

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

  def test_local_user_reads_user_env_var
    with_env(USER: "foo") do
      assert_equal("foo", local_user)
    end
  end

  def test_local_user_reads_username_env_var
    with_env(USER: nil, USERNAME: "bar") do
      assert_equal("bar", local_user)
    end
  end

  def test_local_user_reads_whoami_output
    with_env(USER: nil, USERNAME: nil) do
      with_whoami_mock("baz\n") do
        assert_equal("baz", local_user)
      end
    end
  end

  def test_local_user_gracefully_handles_whoami_failure
    with_env(USER: nil, USERNAME: nil) do
      with_whoami_mock(Errno::ENOENT) do
        assert_nil(local_user)
      end
    end
  end

  private

  def local_user
    runtime = Tomo::Testing::MockPluginTester.new.send(:runtime)
    plan = runtime.execution_plan_for([])
    plan.settings.fetch(:local_user)
  end

  def with_env(mock_env)
    orig_env = ENV.to_h.dup
    mock_env.each do |key, value|
      ENV[key.to_s] = value
    end
    yield
  ensure
    orig_env.each do |key, value|
      ENV[key.to_s] = value
    end
  end

  def with_whoami_mock(result, &)
    result_callable = ->(*) { result.is_a?(Exception) ? raise(result) : result }
    Tomo::Runtime.stub(:`, result_callable, &)
  end
end
