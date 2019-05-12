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

  private

  def configure(settings={})
    @tester = Tomo::Testing::MockPluginTester.new(settings: settings)
  end
end
