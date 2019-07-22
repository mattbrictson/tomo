require "test_helper"
require "tomo/plugin/bundler"

class Tomo::Plugin::Bundler::TasksTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new("bundler")
  end

  def test_upgrade_bundler
    @tester.mock_script_result(/^tail .*Gemfile\.lock/, stdout: <<~OUT)
        minitest-ci (~> 3.4)
        minitest-hooks (~> 1.5)
        minitest-reporters (~> 1.3)
        rake (~> 12.3)
        rubocop (= 0.73.0)
        rubocop-performance (= 1.4.0)
        tomo!

      BUNDLED WITH
         2.0.2
    OUT
    @tester.run_task("bundler:upgrade_bundler")
    assert_equal(
      "gem install bundler --conservative --no-document -v 2.0.2",
      @tester.executed_scripts.last
    )
  end

  def test_upgrade_bundler_skips_installation_if_lock_file_is_absent
    @tester.mock_script_result(/^tail .*Gemfile\.lock/, exit_status: 1)
    @tester.run_task("bundler:upgrade_bundler")
    assert_match(/tail .*Gemfile\.lock/, @tester.executed_script)
  end

  def test_upgrade_bundler_with_explicit_version_arg
    @tester.run_task("bundler:upgrade_bundler", "3.0.0")
    assert_equal(
      "gem install bundler --conservative --no-document -v 3.0.0",
      @tester.executed_script
    )
  end
end
