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
