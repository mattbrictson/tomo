require "test_helper"
require "tomo/plugin/puma"

class Tomo::Plugin::Puma::TasksTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::MockPluginTester.new(
      "bundler",
      "puma",
      settings: {
        current_path: "/app/current"
      }
    )
  end

  # TODO
end
