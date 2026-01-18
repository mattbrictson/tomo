# frozen_string_literal: true

require "tomo/plugin/nodenv"

class Tomo::Plugin::Nodenv::TasksTest < TomoTest
  def test_install_modifies_bashrc
    bashrc = <<~SH
      # example bashrc
    SH
    tester = configure(nodenv_node_version: "10.15.3")
    tester.mock_script_result("cat .bashrc", stdout: bashrc)
    tester.run_task("nodenv:install")

    assert_equal(<<~'CMD'.strip, tester.executed_scripts[2])
      echo -n if\ \[\ -d\ \$HOME/.nodenv\ \]\;\ then'
      '\ \ export\ PATH\=\"\$HOME/.nodenv/bin:\$PATH\"'
      '\ \ eval\ \"\$\(nodenv\ init\ -\)\"'
      'fi'
      '\#\ example\ bashrc'
      ' > .bashrc
    CMD
  end

  def test_install_does_not_modify_bashrc_if_already_modified
    bashrc = <<~SH
      if [ -d $HOME/.nodenv ]; then
        export PATH="$HOME/.nodenv/bin:$PATH"
        eval "$(nodenv init -)"
      fi
    SH
    tester = configure(nodenv_node_version: "10.15.3")
    tester.mock_script_result("cat .bashrc", stdout: bashrc)
    tester.run_task("nodenv:install")

    assert_empty tester.executed_scripts.grep(/echo/)
  end

  def test_install_uses_nodenv_to_install_specified_version_of_node
    tester = configure(nodenv_node_version: "10.15.3")
    tester.run_task("nodenv:install")
    refute_empty tester.executed_scripts.grep("nodenv install 10.15.3")
  end

  def test_install_skips_node_if_already_installed
    tester = configure(nodenv_node_version: "10.15.3")
    tester.mock_script_result("nodenv versions", stdout: <<~OUT)
        10.15.1
        10.15.2
      * 10.15.3
    OUT
    tester.run_task("nodenv:install")
    assert_empty tester.executed_scripts.grep(/nodenv install/)
  end

  def test_install_makes_the_specified_node_version_active
    tester = configure(nodenv_node_version: "10.15.3")
    tester.run_task("nodenv:install")
    refute_empty tester.executed_scripts.grep("nodenv global 10.15.3")
  end

  def test_install_uses_npm_to_install_yarn_by_default
    tester = configure(nodenv_node_version: "10.15.3")
    tester.run_task("nodenv:install")
    refute_empty tester.executed_scripts.grep("npm i -g yarn")
  end

  def test_install_uses_npm_to_install_specified_version_of_yarn
    tester = configure(
      nodenv_node_version: "10.15.3",
      nodenv_yarn_version: "1.17.3"
    )
    tester.run_task("nodenv:install")
    refute_empty tester.executed_scripts.grep("npm i -g yarn@1.17.3")
  end

  def test_install_skips_yarn_if_explicitly_disabled
    tester = configure(
      nodenv_node_version: "10.15.3",
      nodenv_install_yarn: false
    )
    tester.run_task("nodenv:install")
    assert_empty tester.executed_scripts.grep(/yarn/)
  end

  def test_install_fails_with_message_if_nodenv_node_version_is_not_specified
    tester = configure
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.node-version", exit_status: 1)
    error = assert_raises(Tomo::Runtime::TaskAbortedError) do
      tester.run_task("nodenv:install")
    end
    assert_match(/could not guess node version/i, error.message)
  end

  def test_install_uses_node_version_file_for_node_version
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.node-version", stdout: "16.15.0\n")
    tester.run_task("nodenv:install")
    assert_includes(tester.executed_scripts, "nodenv install 16.15.0")
  end

  def test_install_uses_a_placeholder_node_version_during_dry_run_so_it_runs_without_error
    Tomo.dry_run = true
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.run_task("nodenv:install")
    assert_includes(tester.executed_scripts, "nodenv install DRY_RUN_PLACEHOLDER")
  ensure
    Tomo.dry_run = false
  end

  private

  def configure(settings={})
    Tomo::Testing::MockPluginTester.new("nodenv", settings:)
  end
end
