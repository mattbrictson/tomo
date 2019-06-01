require "test_helper"
require "tomo/plugin/rails"

class Tomo::Plugin::Rails::TasksTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new("rails")
  end

  def test_log_tail
    @tester.run_task("rails:log_tail", "-F")
    assert_equal(
      "tail -F /var/www/testing/current/log/${RAILS_ENV}.log",
      @tester.executed_script
    )
  end
end
