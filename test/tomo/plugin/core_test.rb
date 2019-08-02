require "test_helper"
require "tomo/plugin/core"

class Tomo::Plugin::CoreTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new
  end

  def test_local_user_setting_uses_helper_method
    assert_equal(local_user, @tester.settings[:local_user])
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
    Tomo::Plugin::Core.send(:local_user)
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

  def with_whoami_mock(result, &block)
    result_callable = ->(*) { result.is_a?(Exception) ? raise(result) : result }
    Tomo::Plugin::Core.stub(:`, result_callable, &block)
  end
end
