require "test_helper"

class Tomo::CLITest < Minitest::Test
  include Tomo::Testing::Local

  def test_execute_task_with_implicit_run_command
    in_temp_dir do
      tomo "init"
      stdout, _stderr = tomo "bundler:install", "--dry-run"
      assert_match "Simulated bundler:install", stdout
    end
  end

  private

  def tomo(*args)
    capturing_logger_output do
      Tomo::CLI.new.call(args.flatten)
    end
  ensure
    Tomo.debug = false
    Tomo.dry_run = false
    Tomo::CLI.show_backtrace = false
    Tomo::CLI::Completions.instance_variable_set(:@active, false)
  end

  def capturing_logger_output
    orig_logger = Tomo.logger
    stdout_io = StringIO.new
    stderr_io = StringIO.new
    Tomo.logger = Tomo::Logger.new(stdout: stdout_io, stderr: stderr_io)
    yield
    [stdout_io.string, stderr_io.string]
  ensure
    Tomo.logger = orig_logger
  end
end
