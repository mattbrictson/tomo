require "test_helper"

class Tomo::CLI::CompletionsTest < Minitest::Test
  include Tomo::Testing::Local

  def test_completions_include_setting_names
    output = in_temp_dir do
      tomo "init"
      tomo "--complete", "deploy", "-s"
    end

    assert_match(/^git_branch=$/, output)
    assert_match(/^git_url=$/, output)
  end

  def test_completes_task_name_even_without_run_command
    output = in_temp_dir do
      tomo "init"
      tomo "--complete-word", "rails:"
    end

    assert_match(/^console $/, output)
    assert_match(/^db_migrate $/, output)
  end

  private

  def tomo(*args)
    with_tomo_gemfile do
      capture("bundle", "exec", "tomo", *args.flatten)
    end
  end
end
