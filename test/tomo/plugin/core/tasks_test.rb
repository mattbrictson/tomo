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

  def test_symlink_shared_does_nothing_if_no_linked_dirs_or_files
    configure(linked_dirs: [], linked_files: [])
    @tester.run_task("core:symlink_shared")
    assert_nil(@tester.executed_script)
  end

  def test_symlink_shared_creates_file_links
    configure(linked_files: %w[config/database.yml .env])
    @tester.run_task("core:symlink_shared")
    assert_equal(
      [
        "mkdir -p /var/www/testing/shared/config "\
                 "/var/www/testing/current/config",
        "ln -sfn /var/www/testing/shared/config/database.yml "\
                "/var/www/testing/current/config/database.yml",
        "ln -sfn /var/www/testing/shared/.env /var/www/testing/current/.env"
      ],
      @tester.executed_scripts
    )
  end

  def test_symlink_shared_deletes_existing_dirs_and_creates_links
    configure(linked_dirs: %w[.bundle public/assets])
    @tester.run_task("core:symlink_shared")
    assert_equal(
      [
        "mkdir -p /var/www/testing/shared/.bundle "\
                 "/var/www/testing/shared/public/assets " \
                 "/var/www/testing/current/public",
        "cd /var/www/testing/current && rm -rf .bundle public/assets",
        "ln -sf /var/www/testing/shared/.bundle "\
               "/var/www/testing/current/.bundle",
        "ln -sf /var/www/testing/shared/public/assets "\
               "/var/www/testing/current/public/assets"
      ],
      @tester.executed_scripts
    )
  end

  def test_symlink_current
    configure(
      release_path: "/app/releases/20190416235621",
      current_path: "/app/current"
    )
    @tester.run_task("core:symlink_current")

    token = @tester.executed_scripts.first[/current-(\S+)/, 1]
    assert_equal(
      [
        "ln -sf /app/releases/20190416235621 /app/current-#{token}",
        "mv -fT /app/current-#{token} /app/current"
      ],
      @tester.executed_scripts
    )
  end

  def test_symlink_current_does_nothing_if_release_is_already_current
    configure(
      release_path: "/app/current",
      current_path: "/app/current"
    )
    @tester.run_task("core:symlink_current")
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
