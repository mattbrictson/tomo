# frozen_string_literal: true

require "tomo/plugin/puma"

class Tomo::Plugin::Puma::TasksTest < TomoTest
  setup do
    configure
  end

  def test_setup_systemd
    @tester.mock_script_result("ls -A1 /var/lib/systemd/linger", stdout: "testing\n")
    expected_scripts = [
      "ls -A1 /var/lib/systemd/linger",
      "mkdir -p .config/systemd/user",
      "> .config/systemd/user/puma_test.socket",
      "> .config/systemd/user/puma_test.service",
      "systemctl --user daemon-reload",
      "systemctl --user enable puma_test.service puma_test.socket"
    ]

    @tester.run_task("puma:setup_systemd")
    expected_scripts.zip(@tester.executed_scripts).each do |expected, actual|
      assert_match(expected, actual)
    end
  end

  def test_setup_systemd_uses_notify_type_by_default
    @tester.mock_script_result("ls -A1 /var/lib/systemd/linger", stdout: "testing\n")
    @tester.run_task("puma:setup_systemd")

    assert_match("Type\\=notify", @tester.executed_scripts[3])
  end

  def test_setup_systemd_can_be_configured_to_use_simple_type
    configure(puma_systemd_service_type: "simple")
    @tester.mock_script_result("ls -A1 /var/lib/systemd/linger", stdout: "testing\n")
    @tester.run_task("puma:setup_systemd")

    assert_match("Type\\=simple", @tester.executed_scripts[3])
  end

  def test_setup_systemd_dies_if_linger_is_disabled
    @tester.mock_script_result("ls -A1 /var/lib/systemd/linger", stdout: "some_other_user\n")
    error = assert_raises(Tomo::Runtime::TaskAbortedError) do
      @tester.run_task("puma:setup_systemd")
    end
    assert_match("Linger must be enabled", error.to_console)
  end

  def test_start
    @tester.run_task("puma:start")
    assert_equal("systemctl --user start puma_test.socket puma_test.service", @tester.executed_script)
  end

  def test_stop
    @tester.run_task("puma:stop")
    assert_equal("systemctl --user stop puma_test.socket puma_test.service", @tester.executed_script)
  end

  def test_status
    @tester.run_task("puma:status")
    assert_equal("systemctl --user status puma_test.socket puma_test.service", @tester.executed_script)
  end

  def test_restart
    @tester.run_task("puma:restart")
    assert_equal(
      [
        "systemctl --user start puma_test.socket",
        "systemctl --user restart puma_test.service"
      ],
      @tester.executed_scripts
    )
  end

  def test_check_active_shows_logs_and_dies_if_service_is_inactive
    @tester.mock_script_result("systemctl --user is-active puma_test.service", exit_status: 1)
    error = assert_raises(Tomo::Runtime::TaskAbortedError) do
      @tester.run_task("puma:check_active")
    end
    assert_match("puma failed to start", error.to_console)

    assert_equal(
      [
        "systemctl --user is-active puma_test.service",
        "systemctl --user status puma_test.service",
        "journalctl -q -n 50 --user-unit=puma_test.service"
      ],
      @tester.executed_scripts
    )
  end

  def test_log
    assert_raises(Tomo::Testing::MockedExecError) do
      @tester.run_task("puma:log", "-f")
    end
    assert_equal(
      "journalctl -q --user-unit=puma_test.service -f",
      @tester.executed_script
    )
  end

  def test_tail_log
    assert_raises(Tomo::Testing::MockedExecError) do
      @tester.run_task("puma:tail_log")
    end
    assert_equal(
      "journalctl -q --user-unit=puma_test.service -f",
      @tester.executed_script
    )
  end

  private

  def configure(settings={})
    @tester = Tomo::Testing::MockPluginTester.new(
      "puma",
      settings: {
        application: "test",
        current_path: "/app/current"
      }.merge(settings)
    )
  end
end
