require "test_helper"
require "tomo/plugin/rbenv"

class Tomo::Plugin::Rbenv::TasksTest < Minitest::Test
  def test_install_uses_ruby_version_file_for_ruby_version
    tester = configure(release_path: "/tmp/tomo/20201027184921")
    tester.mock_script_result("cat /tmp/tomo/20201027184921/.ruby-version", stdout: "2.7.1\n")
    tester.run_task("rbenv:install")
    assert_equal("CFLAGS=-O3 rbenv install 2.7.1 --verbose", tester.executed_scripts[-2])
  end

  def test_install_uses_rbenv_ruby_version_for_ruby_version
    tester = configure(
      rbenv_ruby_version: "2.6.6",
      release_path: "/tmp/tomo/20201027184921"
    )
    tester.run_task("rbenv:install")
    assert_equal("CFLAGS=-O3 rbenv install 2.6.6 --verbose", tester.executed_scripts[-2])
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
    assert_equal("CFLAGS=-O3 rbenv install 3.2.0 --verbose", tester.executed_scripts[-2])
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

  def test_install_prepends_to_bashrc_if_rbenv_init_exists_but_path_is_not_set
    tester = configure(
      rbenv_ruby_version: "3.1.3",
      release_path: "/tmp/tomo/20201027184921"
    )
    tester.mock_script_result("cat .bashrc", stdout: <<~STDOUT)
      # ~/.bashrc: executed by bash(1) for non-login shells.
      # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
      # for examples

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
            *) return;;
      esac

      # Added by `rbenv init` on Sat May 25 00:47:06 UTC 2024
      eval "$(~/.rbenv/bin/rbenv init - bash)"
    STDOUT

    tester.run_task("rbenv:install")
    assert_match(/> .bashrc/, tester.executed_scripts[2])
    assert_match(<<~EXPECTED.shellescape, tester.executed_scripts[2])
      if [ -d $HOME/.rbenv ]; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
      fi

      # ~/.bashrc: executed by bash(1) for non-login shells.
      # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
      # for examples

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
            *) return;;
      esac

      # Added by `rbenv init` on Sat May 25 00:47:06 UTC 2024
      eval "$(~/.rbenv/bin/rbenv init - bash)"
    EXPECTED
  end

  def test_install_does_not_prepend_to_bashrc_if_rbenv_path_and_init_are_already_present
    tester = configure(
      rbenv_ruby_version: "3.1.3",
      release_path: "/tmp/tomo/20201027184921"
    )
    tester.mock_script_result("cat .bashrc", stdout: <<~STDOUT)
      if [ -d $HOME/.rbenv ]; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(rbenv init -)"
      fi

      # ~/.bashrc: executed by bash(1) for non-login shells.
      # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
      # for examples

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
            *) return;;
      esac

      # Added by `rbenv init` on Sat May 25 00:47:06 UTC 2024
      eval "$(~/.rbenv/bin/rbenv init - bash)"
    STDOUT

    tester.run_task("rbenv:install")
    assert_empty(tester.executed_scripts.grep(/> .bashrc/))
  end

  private

  def configure(settings={})
    Tomo::Testing::MockPluginTester.new("rbenv", settings:)
  end
end
