require "test_helper"
require "tomo/plugin/bundler"

class Tomo::Plugin::Bundler::TasksTest < Minitest::Test
  def test_install
    tester = configure(release_path: "/app/release")
    tester.mock_script_result(/bundle check/, exit_status: 1)
    tester.run_task("bundler:install")
    assert_equal(
      [
        "cd /app/release && bundle check",
        "cd /app/release && bundle install"
      ],
      tester.executed_scripts
    )
  end

  def test_config_writes_local_config_file
    tester = configure(
      bundler_config_path: ".bundle/config",
      bundler_deployment: true,
      bundler_gemfile: "Gemfile.prod",
      bundler_ignore_messages: true,
      bundler_jobs: 12,
      bundler_path: "/app/bundle",
      bundler_retry: 2,
      bundler_without: %w[development test staging],
      release_path: "/app/release"
    )
    tester.run_task("bundler:config")
    assert_equal("mkdir -p .bundle", tester.executed_scripts.first)
    assert_equal(<<~'SCRIPT'.strip, tester.executed_scripts.last)
      echo -n ---'
      'BUNDLE_DEPLOYMENT:\ \'true\''
      'BUNDLE_GEMFILE:\ Gemfile.prod'
      'BUNDLE_IGNORE_MESSAGES:\ \'true\''
      'BUNDLE_JOBS:\ \'12\''
      'BUNDLE_PATH:\ \"/app/bundle\"'
      'BUNDLE_RETRY:\ \'2\''
      'BUNDLE_WITHOUT:\ development:test:staging'
      ' > .bundle/config
    SCRIPT
  end

  def test_config_excludes_nil_settings_from_config_file
    tester = configure(
      bundler_config_path: ".bundle/config",
      bundler_deployment: false,
      bundler_gemfile: nil,
      bundler_ignore_messages: false,
      bundler_jobs: nil,
      bundler_path: "/app/bundle",
      bundler_retry: nil,
      bundler_without: nil,
      release_path: "/app/release"
    )
    tester.run_task("bundler:config")
    assert_equal(<<~'SCRIPT'.strip, tester.executed_scripts.last)
      echo -n ---'
      'BUNDLE_DEPLOYMENT:\ \'false\''
      'BUNDLE_IGNORE_MESSAGES:\ \'false\''
      'BUNDLE_PATH:\ \"/app/bundle\"'
      ' > .bundle/config
    SCRIPT
  end

  def test_upgrade_bundler_uses_lock_file_for_version
    tester = configure
    tester.mock_script_result(/^tail .*Gemfile\.lock/, stdout: <<~OUT)
        minitest-ci (~> 3.4)
        minitest-hooks (~> 1.5)
        minitest-reporters (~> 1.3)
        rake (~> 12.3)
        rubocop (= 0.73.0)
        rubocop-performance (= 1.4.0)
        tomo!

      BUNDLED WITH
         2.0.2
    OUT
    tester.run_task("bundler:upgrade_bundler")
    assert_equal("gem install bundler --conservative --no-document -v 2.0.2", tester.executed_scripts.last)
  end

  def test_upgrade_bundler_uses_setting_for_version
    tester = configure(bundler_version: "2.0.1")
    tester.run_task("bundler:upgrade_bundler")
    assert_equal("gem install bundler --conservative --no-document -v 2.0.1", tester.executed_script)
  end

  def test_upgrade_bundler_dies_if_lock_file_is_absent_and_no_version_specified
    tester = configure(bundler_version: nil)
    tester.mock_script_result(/^tail .*Gemfile\.lock/, exit_status: 1)
    error = assert_raises(Tomo::Runtime::TaskAbortedError) do
      tester.run_task("bundler:upgrade_bundler")
    end
    assert_match(/Gemfile\.lock/, error.message)
    assert_match(/tail .*Gemfile\.lock/, tester.executed_script)
  end

  private

  def configure(settings={})
    Tomo::Testing::MockPluginTester.new("bundler", settings:)
  end
end
