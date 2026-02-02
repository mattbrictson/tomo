# frozen_string_literal: true

require "tomo/plugin/env"

class Tomo::Plugin::Env::TasksTest < TomoTest
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
    assert_equal(<<~'EXPECTED'.strip, tester.executed_scripts[4])
      echo -n export\ RAILS_MAX_THREADS\=6'
      'export\ RAILS_ENV\=production'
      ' > /app/envrc
    EXPECTED
  end

  def test_setup_does_not_modify_bashrc_if_it_is_already_set_up
    tester = Tomo::Testing::MockPluginTester.new(
      "env",
      settings: {
        bashrc_path: ".bashrc",
        env_path: "/app/envrc"
      }
    )

    tester.mock_script_result("cat .bashrc", stdout: <<~STDOUT)
      if [ -f /app/envrc ]; then  # DO NOT MODIFY THESE LINES
        . /app/envrc              # ENV MAINTAINED BY TOMO
      fi                          # END TOMO ENV

      # ~/.bashrc: executed by bash(1) for non-login shells.
      # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
      # for examples

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
            *) return;;
      esac
    STDOUT

    tester.run_task("env:setup")
    assert_empty(tester.executed_scripts.grep(/> .bashrc/))
  end

  def test_setup_fails_if_wrong_envrc_already_exists_in_bashrc
    tester = Tomo::Testing::MockPluginTester.new(
      "env",
      settings: {
        bashrc_path: ".bashrc",
        env_path: "/var/www/newapp/envrc"
      }
    )

    tester.mock_script_result("cat .bashrc", stdout: <<~STDOUT)
      if [ -f /var/www/oldapp/envrc ]; then  # DO NOT MODIFY THESE LINES
        . /var/www/oldapp/envrc              # ENV MAINTAINED BY TOMO
      fi                                     # END TOMO ENV

      # ~/.bashrc: executed by bash(1) for non-login shells.
      # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
      # for examples

      # If not running interactively, don't do anything
      case $- in
          *i*) ;;
            *) return;;
      esac
    STDOUT

    error = assert_raises(Tomo::Runtime::TaskAbortedError) { tester.run_task("env:setup") }
    assert_match("only one application can be deployed", error.message)
    assert_match("/var/www/oldapp/envrc", error.message)
  end

  def test_executes_chmod_to_reduce_visibility_of_envrc_file_upon_creation
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
    assert_equal("chmod 600 /app/envrc", tester.executed_scripts.last)
  end

  def test_setup_generates_a_random_value_for_var_marked_as_generate_secret
    tester = Tomo::Testing::MockPluginTester.new(
      "env",
      settings: {
        env_path: "/app/envrc",
        env_vars: {
          RAILS_ENV: "production",
          SECRET_KEY_BASE: :generate_secret
        }
      }
    )
    tester.run_task("env:setup")
    assert_match(/SECRET_KEY_BASE\\=\h{64}/, tester.executed_scripts[4])
  end

  def test_does_not_overwrite_previously_generated_secret
    tester = Tomo::Testing::MockPluginTester.new(
      "env",
      settings: {
        env_path: "/app/envrc",
        env_vars: {
          RAILS_ENV: "production",
          SECRET_KEY_BASE: :generate_secret
        }
      }
    )
    tester.mock_script_result("cat /app/envrc", stdout: <<~STDOUT)
      export SECRET_KEY_BASE=do-not-replace-me
    STDOUT
    tester.run_task("env:update")

    assert_match(/SECRET_KEY_BASE\\=do-not-replace-me/, tester.executed_scripts[1])
  end
end
