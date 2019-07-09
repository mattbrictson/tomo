require "test_helper"

class Tomo::CLI::CompletionsTest < Minitest::Test
  def test_completions_include_setting_names
    output = Tomo::Testing::Local.in_temp_dir do
      capture "bundle exec tomo init"
      capture "bundle exec tomo --complete deploy -s"
    end

    assert_match(/^git_branch=$/, output)
    assert_match(/^git_url=$/, output)
  end

  private

  def capture(command)
    Tomo::Testing::Local.with_tomo_gemfile do
      Tomo::Testing::Local.capture(command)
    end
  end
end
