# frozen_string_literal: true

require "test_helper"
require "tomo/plugin/core"

class Tomo::Plugin::Core::HelpersTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new(
      settings: { application: "test" }
    )
  end

  def test_capture_returns_stdout_not_stderr
    @tester.mock_script_result(stderr: "oh no", stdout: "hello world\n")
    captured = @tester.call_helper(:capture, "greet")
    assert_equal("hello world\n", captured)
  end

  def test_capture_silences_output
    @tester.mock_script_result(stdout: "hello world\n")
    @tester.call_helper(:capture, "greet")
    refute_match(/hello world/, @tester.stdout)
  end

  def test_capture_raises_on_error
    @tester.mock_script_result(stderr: "oh no", exit_status: 1)
    assert_raises(Tomo::SSH::ScriptError) do
      @tester.call_helper(:capture, "greet")
    end
  end

  def test_run?
    result = @tester.call_helper(:run?, "echo hello world")
    assert(result)

    @tester.mock_script_result(exit_status: 1)
    result = @tester.call_helper(:run?, "boom")
    refute(result)
  end

  def test_write_replaces_the_file
    @tester.call_helper(:write, text: "hello there", to: "/a/file")
    assert_equal("echo -n hello\\ there > /a/file", @tester.executed_script)
  end

  def test_write_appends_to_the_file
    @tester.call_helper(:write, text: "hi\nworld!", to: "/a/file", append: true)
    assert_equal("echo -n hi'\n'world\\! >> /a/file", @tester.executed_script)
  end

  def test_write_does_not_echo_the_text
    @tester.call_helper(:write, text: "hello", to: "/a/file")
    refute_match(/hello/, @tester.stdout)
    assert_match(%r{Writing 5 bytes to /a/file}, @tester.stdout)
  end

  def test_write_accepts_template
    tmpl_path = File.expand_path("../../../fixtures/template.erb", __dir__)
    @tester.call_helper(:write, template: tmpl_path, to: "/a/file")
    assert_equal(<<~'EXPECTED'.strip, @tester.executed_script)
      echo -n Hello,\ test\!'
      ' > /a/file
    EXPECTED
  end

  def test_write_raises_error_if_text_and_template_specified
    assert_raises(ArgumentError, "specify text: or template:") do
      @tester.call_helper(:write, text: "text", template: "tmpl", to: "/a/file")
    end
  end

  def test_write_raises_error_neither_text_nor_template_specified
    assert_raises(ArgumentError, "specify text: or template:") do
      @tester.call_helper(:write, to: "/a/file")
    end
  end

  def test_ln_sf
    @tester.call_helper(:ln_sf, "/shared/file", "/current/file")
    assert_equal("ln -sf /shared/file /current/file", @tester.executed_script)
  end

  def test_ln_sfn
    @tester.call_helper(:ln_sfn, "/shared/file", "/current/file")
    assert_equal("ln -sfn /shared/file /current/file", @tester.executed_script)
  end

  def test_mkdir_p
    @tester.call_helper(:mkdir_p, "/a/path", "/another/file name")
    assert_equal("mkdir -p /a/path /another/file\\ name", @tester.executed_script)
  end

  def test_rm_rf
    @tester.call_helper(:rm_rf, "/one/file", "/two/file")
    assert_equal("rm -rf /one/file /two/file", @tester.executed_script)
  end

  def test_list_files
    @tester.mock_script_result("ls -A1 /path/to/dir", stdout: <<~OUT)
      .hidden
      README.md
      bar
      foo
    OUT
    result = @tester.call_helper(:list_files, "/path/to/dir")
    assert_equal("ls -A1 /path/to/dir", @tester.executed_script)
    assert_equal(%w[.hidden README.md bar foo], result)
  end

  def test_list_files_with_no_arg
    @tester.call_helper(:list_files)
    assert_equal("ls -A1", @tester.executed_script)
  end

  def test_command_available?
    result = @tester.call_helper(:command_available?, "ruby")
    assert_equal("which ruby", @tester.executed_script)
    assert(result)

    @tester.mock_script_result(exit_status: 1)
    result = @tester.call_helper(:command_available?, "ruby")
    refute(result)
  end

  def test_file?
    result = @tester.call_helper(:file?, "/some/path")
    assert_equal("[ -f /some/path ]", @tester.executed_script)
    assert(result)

    @tester.mock_script_result(exit_status: 1)
    result = @tester.call_helper(:file?, "/some/path")
    refute(result)
  end

  def test_executable?
    result = @tester.call_helper(:executable?, "/bin/sh")
    assert_equal("[ -x /bin/sh ]", @tester.executed_script)
    assert(result)

    @tester.mock_script_result(exit_status: 1)
    result = @tester.call_helper(:executable?, "/bin/sh")
    refute(result)
  end

  def test_directory?
    result = @tester.call_helper(:directory?, "/home/deployer")
    assert_equal("[ -d /home/deployer ]", @tester.executed_script)
    assert(result)

    @tester.mock_script_result(exit_status: 1)
    result = @tester.call_helper(:directory?, "/home/deployer")
    refute(result)
  end
end
