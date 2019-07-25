require "test_helper"

class Tomo::CLITest < Minitest::Test
  def setup
    @tester = Tomo::Testing::CLITester.new
  end

  def test_execute_task_with_implicit_run_command
    @tester.run "init"
    @tester.run "bundler:install", "--dry-run"
    assert_match "Simulated bundler:install", @tester.stdout
  end
end
