# frozen_string_literal: true

require "test_helper"
require "tomo/plugin/direct"

class Tomo::Plugin::Direct::TasksTest < Minitest::Test
  def setup
    @executed_commands = []
    Tomo::Plugin::Direct::Helpers.system_proc = ->(cmd) { @executed_commands << cmd }
  end

  def teardown
    Tomo::Plugin::Direct::Helpers.system_proc = ->(cmd) { Kernel.system(cmd, exception: true) }
  end

  def test_create_release_creates_release_directory
    tester = configure
    tester.run_task("direct:create_release")
    assert_includes(tester.executed_scripts, "mkdir -p /app")
  end

  def test_create_release_stores_release_info
    tester = configure
    tester.run_task("direct:create_release")
    assert_includes(tester.stdout, "Streaming archive")
  end

  def test_create_release_uses_configured_source_path
    tester = configure(direct_source_path: "/my/project")
    tester.run_task("direct:create_release")
    assert(@executed_commands.any? { |cmd| cmd.include?("-C /my/project") })
  end

  def test_create_release_includes_default_exclusions
    tester = configure
    tester.run_task("direct:create_release")
    cmd = @executed_commands.first
    assert_includes(cmd, "--exclude=.git")
    assert_includes(cmd, "--exclude=node_modules")
    assert_includes(cmd, "--exclude=.DS_Store")
  end

  def test_create_release_includes_custom_exclusions
    tester = configure(direct_exclusions: %w[spec/ coverage/])
    tester.run_task("direct:create_release")
    cmd = @executed_commands.first
    assert_includes(cmd, "--exclude=spec/")
    assert_includes(cmd, "--exclude=coverage/")
  end

  private

  def configure(settings={})
    defaults = {
      release_path: "/app"
    }
    settings = defaults.merge(settings)
    Tomo::Testing::MockPluginTester.new("direct", settings:)
  end
end
