require "test_helper"
require "tomo/plugin/puma"

class Tomo::Plugin::Puma::TasksTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new(
      "bundler",
      "puma",
      settings: {
        current_path: "/app/current",
        puma_control_url: "tcp://127.0.0.1:9293",
        puma_control_token: "test",
        puma_stdout_path: "/log/puma.out",
        puma_stderr_path: "/log/puma.err"
      }
    )
  end

  def test_restart_uses_pumactl
    @tester.run_task("puma:restart")
    assert_equal(
      "cd /app/current && bundle exec pumactl "\
      "--control-url tcp://127.0.0.1:9293 --control-token test restart",
      @tester.executed_script
    )
  end

  def test_restart_starts_puma_if_pumactl_fails
    @tester.mock_script_result(/pumactl/, exit_status: 1)
    @tester.run_task("puma:restart")
    assert_equal("mkdir -p /log", @tester.executed_scripts[-2])
    assert_equal(
      "cd /app/current && bundle exec puma --daemon "\
      "--control-url tcp://127.0.0.1:9293 --control-token test "\
      "> /log/puma.out 2> /log/puma.err",
      @tester.executed_scripts.last
    )
  end
end
