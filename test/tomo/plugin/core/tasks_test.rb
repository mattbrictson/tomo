require "test_helper"
require "tomo/plugin/core"

class Tomo::Plugin::Core::TasksTest < Minitest::Test
  def setup
    configure
  end

  def test_setup_directories
    @tester.run_task("core:setup_directories")
    assert_equal(
      "mkdir -p /var/www/testing "\
               "/var/www/testing/releases "\
               "/var/www/testing/shared",
      @tester.executed_script
    )
  end

  def test_create_shared_directories
    configure(linked_dirs: %w[foo bar/baz])
    @tester.run_task("core:create_shared_directories")
    assert_equal(
      [
        "mkdir -p /var/www/testing/shared",
        "cd /var/www/testing/shared && mkdir -p foo bar/baz"
      ],
      @tester.executed_scripts
    )
  end

  def test_create_shared_directories_skips_if_no_linked_dirs
    configure(linked_dirs: [])
    @tester.run_task("core:create_shared_directories")
    assert_nil(@tester.executed_script)
  end

  def test_symlink_shared_files
    configure(linked_files: %w[config/database.yml .env])
    @tester.run_task("core:symlink_shared_files")
    assert_equal(
      [
        "mkdir -p /var/www/testing/current/config",
        "ln -sfn /var/www/testing/shared/config/database.yml "\
                "/var/www/testing/current/config/database.yml",
        "ln -sfn /var/www/testing/shared/.env /var/www/testing/current/.env"
      ],
      @tester.executed_scripts
    )
  end

  def test_symlink_shared_files_skips_if_no_linked_files
    configure(linked_files: [])
    @tester.run_task("core:symlink_shared_files")
    assert_nil(@tester.executed_script)
  end

  def test_clean_releases_deletes_oldest_releases_but_not_current
    configure(
      keep_releases: 3,
      releases_path: "/app/releases",
      current_path: "/app/current"
    )
    @tester.mock_script_result("readlink /app/current", stdout: <<~OUT)
      /app/releases/20190420203028
    OUT
    @tester.mock_script_result("cd /app/releases && ls -A1", stdout: <<~OUT)
      ignore
      1234
      20190416235621
      20190424063032
      20190421033621
      20190423040133
      20190420203028
      xx20190510133353
    OUT

    @tester.run_task("core:clean_releases")
    assert_equal(
      [
        "readlink /app/current",
        "cd /app/releases && ls -A1",
        "cd /app/releases && rm -rf 20190416235621 20190421033621"
      ],
      @tester.executed_scripts
    )
  end

  def test_clean_releases_does_not_delete_anything_if_there_are_too_few_releases
    configure(
      keep_releases: 3,
      releases_path: "/app/releases",
      current_path: "/app/current"
    )
    @tester.mock_script_result("cd /app/releases && ls -A1", stdout: <<~OUT)
      ignore
      1234
      20190416235621
      xx20190510133353
    OUT

    @tester.run_task("core:clean_releases")
    assert_equal(
      [
        "readlink /app/current",
        "cd /app/releases && ls -A1"
      ],
      @tester.executed_scripts
    )
  end

  def test_clean_releases_skips_keep_releases_is_nil
    configure(keep_releases: nil)
    @tester.run_task("core:clean_releases")
    assert_empty(@tester.executed_scripts)
  end

  private

  def configure(settings={})
    @tester = Tomo::Testing::MockPluginTester.new(settings: settings)
  end
end
