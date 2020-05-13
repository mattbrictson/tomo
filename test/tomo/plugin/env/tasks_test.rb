require "test_helper"
require "tomo/plugin/env"

class Tomo::Plugin::Env::TasksTest < Minitest::Test
  def test_setup_allows_integer_value
    tester = Tomo::Testing::MockPluginTester.new(
      "env",
      settings: {
        env_path: "/app/envrc",
        env_vars: {
          RAILS_ENV: "production",
          RAILS_MAX_THREADS: 6
        }
      }
    )
    tester.run_task("env:setup")
    assert_equal(<<~'EXPECTED'.strip, tester.executed_scripts[2])
      echo -n export\ RAILS_MAX_THREADS\=6'
      'export\ RAILS_ENV\=production'
      ' > /app/envrc
    EXPECTED
  end
end
