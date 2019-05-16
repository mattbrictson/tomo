require "test_helper"
require "tomo/plugin/core"

class Tomo::Plugin::Core::HelpersDockerTest < Minitest::Test
  include Minitest::Hooks

  def before_all
    super
    @tester = Tomo::Testing::DockerPluginTester.new
    @tester.run(<<~SCRIPT)
      set -e
      mkdir -p ~/test
      touch ~/test/.hidden
      touch ~/test/foo
      touch ~/test/bar
      touch ~/test/README.md
    SCRIPT
  end

  def after_all
    @tester&.teardown
    super
  end

  def test_list_files
    files = @tester.call_helper(:list_files, "/home/deployer/test")
    assert_equal(%w[.hidden README.md bar foo], files.sort)
  end
end
