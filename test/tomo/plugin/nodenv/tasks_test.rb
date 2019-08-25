require "test_helper"
require "tomo/plugin/nodenv"

class Tomo::Plugin::Nodenv::TasksTest < Minitest::Test
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
    bashrc = <<~'SH'
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

  def test_install_uses_npm_to_install_specified_version_of_yarn
    tester = configure(
      nodenv_node_version: "10.15.3",
      nodenv_yarn_version: "1.17.3"
    )
    tester.run_task("nodenv:install")
    refute_empty tester.executed_scripts.grep("npm i -g yarn@1.17.3")
  end

  def test_install_skips_yarn_if_no_yarn_version_specified
    tester = configure(nodenv_node_version: "10.15.3")
    tester.run_task("nodenv:install")
    assert_empty tester.executed_scripts.grep(/yarn/)
  end

  def test_install_raises_if_nodenv_node_version_is_not_specified
    tester = configure
    assert_raises(Tomo::Runtime::SettingsRequiredError) do
      tester.run_task("nodenv:install")
    end
  end

  private

  def configure(settings={})
    Tomo::Testing::MockPluginTester.new("nodenv", settings: settings)
  end
end
