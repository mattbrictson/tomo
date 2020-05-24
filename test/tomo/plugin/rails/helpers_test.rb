require "test_helper"
require "tomo/plugin/rails"

class Tomo::Plugin::Rails::HelpersTest < Minitest::Test
  def test_rake_runs_bundle_exec_rake_in_current_path
    tester = Tomo::Testing::MockPluginTester.new("bundler", "rails", settings: { current_path: "/app/current" })
    tester.call_helper(:rake, "db:migrate")
    assert_equal("cd /app/current && bundle exec rake db:migrate", tester.executed_script)
  end
end
