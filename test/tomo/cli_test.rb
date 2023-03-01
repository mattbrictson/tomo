require "test_helper"

class Tomo::CLITest < Minitest::Test
  def setup
    @tester = Tomo::Testing::CLITester.new
  end

  def test_execute_task_with_implicit_run_command
    @tester.run "init"
    @tester.run "bundler:install", "--dry-run"
    assert_match "Simulated bundler:install", @tester.stdout
  end

  def test_dash_t_is_alias_for_tasks
    @tester.run "init"
    @tester.run "-T"
    assert_match "core:clean_releases", @tester.stdout
    assert_match "core:setup_directories", @tester.stdout
  end

  def test_suggests_installing_missing_plugin
    @tester.run "init"
    @tester.run "foo:setup", raise_on_error: false
    assert_match(/did you forget to install the foo plugin/i, @tester.stderr)
  end

  def test_prints_error_when_config_has_syntax_error
    @tester.in_temp_dir do
      FileUtils.mkdir_p(".tomo")
      File.write(".tomo/config.rb", <<~CONFIG)
        plugin "git"
        deploy do
          run "git:clone
          run "git:create_release"
        end
      CONFIG
    end
    @tester.run "deploy", raise_on_error: false
    assert_match(<<~OUTPUT.strip, @tester.stderr.gsub(/^  /, ""))
      ERROR: Configuration syntax error in .tomo/config.rb at line 4.

        3:   run "git:clone
      → 4:   run "git:create_release"
        5: end

      SyntaxError: .tomo/config.rb:4: syntax error
    OUTPUT
  end

  def test_prints_error_when_config_dsl_is_used_incorrectly
    @tester.in_temp_dir do
      FileUtils.mkdir_p(".tomo")
      File.write(".tomo/config.rb", <<~CONFIG)
        plugin "git"
        deploy do
          run
          run "git:create_release"
        end
      CONFIG
    end
    @tester.run "deploy", raise_on_error: false
    assert_equal(<<~OUTPUT, @tester.stderr.gsub(/^  /, ""))

      ERROR: Configuration syntax error in .tomo/config.rb at line 3.

        2: deploy do
      → 3:   run
        4:   run "git:create_release"

      ArgumentError: wrong number of arguments (given 0, expected 1)

      Visit https://tomo-deploy.com/configuration for syntax reference.
      You can run this command again with --trace for a full backtrace.

    OUTPUT
  end
end
