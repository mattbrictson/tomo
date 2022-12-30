require "test_helper"
require "tomo/plugin/rbenv"

class Tomo::Plugin::Rbenv::TasksTest < Minitest::Test
  def test_install_uses_ruby_version_file_for_ruby_version
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.ruby-version", stdout: "2.7.1\n")
    tester.run_task("rbenv:install")
    assert_equal("CFLAGS=-O3 rbenv install 2.7.1", tester.executed_scripts[-2])
  end

  def test_install_uses_rbenv_ruby_version_for_ruby_version
    tester = configure(
      rbenv_ruby_version: "2.6.6",
      release_path: "/tmp/tomo/20201027184921"
    )
    tester.run_task("rbenv:install")
    assert_equal("CFLAGS=-O3 rbenv install 2.6.6", tester.executed_scripts[-2])
  end

  def test_install_fails_with_message_if_no_ruby_version_specified
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.ruby-version", exit_status: 1)
    error = assert_raises(Tomo::Runtime::TaskAbortedError) do
      tester.run_task("rbenv:install")
    end
    assert_match(/could not guess ruby version/i, error.message)
  end

  def test_install_proceeds_if_similar_but_distinct_version_is_already_installed
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.ruby-version", stdout: "3.2.0\n")
    tester.mock_script_result("rbenv versions", stdout: <<~STDOUT)
        system
        2.7.5
        3.0.5
        3.1.0
        3.1.3
        3.2.0-preview3
      * 3.2.0-rc1 (set by /home/deployer/.rbenv/version)
    STDOUT
    tester.run_task("rbenv:install")
    assert_equal("CFLAGS=-O3 rbenv install 3.2.0", tester.executed_scripts[-2])
  end

  def test_install_is_skipped_if_version_is_already_installed
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.ruby-version", stdout: "3.2.0-rc1\n")
    tester.mock_script_result("rbenv versions", stdout: <<~STDOUT)
        system
        2.7.5
        3.0.5
        3.1.0
        3.1.3
        3.2.0-preview3
        3.2.0-rc1
      * 3.2.0 (set by /home/deployer/.rbenv/version)
    STDOUT
    tester.run_task("rbenv:install")
    assert_empty(tester.executed_scripts.grep(/rbenv install/))
    assert_includes(tester.stdout, "Ruby 3.2.0-rc1 is already installed")
  end

  private

  def configure(settings={})
    Tomo::Testing::MockPluginTester.new("rbenv", settings: settings)
  end
end
