# frozen_string_literal: true

require "tomo/plugin/rails"

class Tomo::Plugin::Rails::TasksTest < TomoTest
  def test_db_console
    tester = Tomo::Testing::MockPluginTester.new(
      "bundler", "rails", settings: { current_path: "/app/current" }
    )
    assert_raises(Tomo::Testing::MockedExecError) { tester.run_task("rails:db_console") }
    assert_equal("cd /app/current && bundle exec rails dbconsole --include-password", tester.executed_script)
  end
end
