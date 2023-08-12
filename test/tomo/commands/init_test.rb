require "test_helper"

class Tomo::Commands::InitTest < Minitest::Test
  def setup
    @tester = Tomo::Testing::CLITester.new
  end

  def test_includes_node_version_setting_in_generated_config
    @tester.in_temp_dir do
      with_backtick_stub("node --version", "v16.14.0\n") do
        @tester.run "init"

        assert_match('set nodenv_node_version: "16.14.0"', File.read(".tomo/config.rb"))
      end
    end
  end

  def test_doesnt_include_node_version_setting_if_nodenv_version_file_is_present
    @tester.in_temp_dir do
      with_backtick_stub("node --version", "v16.14.0\n") do
        File.write ".node-version", "16.14.0\n"
        @tester.run "init"

        refute_match(/nodenv_node_version/, File.read(".tomo/config.rb"))
      end
    end
  end

  def test_uses_default_branch_on_new_empty_repo
    @tester.in_temp_dir do
      Tomo::Testing::Local.capture("git init --initial-branch=develop")
      @tester.run "init"

      assert_match('set git_branch: "develop"', File.read(".tomo/config.rb"))
    end
  end

  def test_uses_main_branch_if_it_exists
    @tester.in_temp_dir do
      Tomo::Testing::Local.capture("git init --initial-branch=main")
      Tomo::Testing::Local.capture("git commit --allow-empty -m init")
      Tomo::Testing::Local.capture("git checkout -b develop")
      @tester.run "init"

      assert_match('set git_branch: "main"', File.read(".tomo/config.rb"))
    end
  end

  def test_uses_master_branch_if_it_exists
    @tester.in_temp_dir do
      Tomo::Testing::Local.capture("git init --initial-branch=master")
      Tomo::Testing::Local.capture("git commit --allow-empty -m init")
      Tomo::Testing::Local.capture("git checkout -b develop")
      @tester.run "init"

      assert_match('set git_branch: "master"', File.read(".tomo/config.rb"))
    end
  end

  def test_uses_current_branch_as_fallback
    @tester.in_temp_dir do
      Tomo::Testing::Local.capture("git init --initial-branch=develop")
      Tomo::Testing::Local.capture("git commit --allow-empty -m init")
      Tomo::Testing::Local.capture("git checkout -b install-tomo")
      @tester.run "init"

      assert_match('set git_branch: "install-tomo"', File.read(".tomo/config.rb"))
    end
  end

  def test_generates_a_sample_plugin_with_comment
    @tester.in_temp_dir do
      @tester.run "init"

      app = File.basename(File.expand_path("."))
      assert_match(%r{^# https://tomo-deploy.com}, File.read(".tomo/plugins/#{app}.rb"))
    end
  end

  private

  def with_backtick_stub(command, result)
    Tomo::Commands::Init.define_method(:`) do |arg|
      arg == command ? result : Kernel.send(:`, arg)
    end
    yield
  ensure
    Tomo::Commands::Init.remove_method(:`)
  end
end
