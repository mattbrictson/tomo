# frozen_string_literal: true

class Tomo::CLI::CompletionsTest < TomoTest
  setup do
    @tester = Tomo::Testing::CLITester.new
  end

  def test_completions_include_setting_names
    @tester.run "init"
    @tester.run "--complete", "deploy", "-s"

    assert_match(/^git_branch=$/, @tester.stdout)
    assert_match(/^git_url=$/, @tester.stdout)
  end

  def test_completes_task_name_even_without_run_command
    @tester.run "init"
    @tester.run "--complete-word", "rails:"

    assert_match(/^console $/, @tester.stdout)
    assert_match(/^db_migrate $/, @tester.stdout)
  end
end
