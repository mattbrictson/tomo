require "test_helper"

class Tomo::CLITest < Minitest::Test
  include Tomo::Testing::Local

  def test_execute_task_with_implicit_run_command
    in_temp_dir do
      tomo "init"
      tomo "bundler:install", "--dry-run"
      assert_match "Simulated bundler:install", stdout
    end
  end

  private

  attr_reader :stdout

  def tomo(*args)
    with_tomo_gemfile do
      @stdout = capture(["bundle", "exec", "tomo", *args.flatten].join(" "))
    end
  end
end
