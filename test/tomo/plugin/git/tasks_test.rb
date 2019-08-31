require "test_helper"
require "tomo/plugin/git"

class Tomo::Plugin::Git::TasksTest < Minitest::Test
  def test_create_release_uses_branch_if_specified
    tester = configure(git_branch: "develop")
    tester.run_task("git:create_release")
    assert_equal(
      "cd /repo && git archive develop | tar -x -f - -C /app",
      tester.executed_scripts.grep(/git archive/).first
    )
  end

  def test_create_release_uses_ref_if_specified
    tester = configure(git_branch: nil, git_ref: "a944898")
    tester.run_task("git:create_release")
    assert_equal(
      "cd /repo && git archive a944898 | tar -x -f - -C /app",
      tester.executed_scripts.grep(/git archive/).first
    )
  end

  def test_create_release_uses_ref_if_both_branch_and_ref_specified
    tester = configure(git_branch: "master", git_ref: "a944898")
    tester.run_task("git:create_release")
    assert_equal(
      "cd /repo && git archive a944898 | tar -x -f - -C /app",
      tester.executed_scripts.grep(/git archive/).first
    )
    assert_equal(<<~ERROR, tester.stderr)
      WARNING: :git_ref (a944898) and :git_branch (master) are both specified. Ignoring :git_branch.
    ERROR
  end

  def test_create_release_raises_error_if_branch_and_ref_both_nil
    tester = configure(git_branch: nil, git_ref: nil)
    assert_raises(Tomo::Runtime::SettingsRequiredError) do
      tester.run_task("git:create_release")
    end
  end

  private

  def configure(settings={})
    defaults = {
      git_env: {},
      git_repo_path: "/repo",
      release_path: "/app"
    }
    settings = defaults.merge(settings)
    Tomo::Testing::MockPluginTester.new("git", settings: settings)
  end
end
