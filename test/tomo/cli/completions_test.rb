require "test_helper"
require "fileutils"
require "open3"
require "securerandom"
require "tmpdir"

class Tomo::CLI::CompletionsTest < Minitest::Test
  def test_completions_include_setting_names
    output = in_temp_dir do
      capture! "bundle exec tomo init"
      capture! "bundle exec tomo --complete deploy -s"
    end

    assert_match(/^git_branch=$/, output)
    assert_match(/^git_url=$/, output)
  end

  private

  def in_temp_dir(&block)
    dir = File.join(Dir.tmpdir, "tomo_test_#{SecureRandom.hex(8)}")
    FileUtils.mkdir_p(dir)
    Dir.chdir(dir, &block)
  end

  def capture!(command)
    Bundler.with_original_env do
      gemfile = File.expand_path("../../../Gemfile", __dir__)
      output, status = Open3.capture2({ "BUNDLE_GEMFILE" => gemfile }, command)
      raise "Command failed: #{command}" unless status.success?

      output
    end
  end
end
