require "test_helper"

class Tomo::CLI::CompletionsTest < Minitest::Test
  include Tomo::Testing::Local

  def test_completions_include_setting_names
    output, _stderr = in_temp_dir do
      tomo "init"
      tomo "--complete", "deploy", "-s"
    end

    assert_match(/^git_branch=$/, output)
    assert_match(/^git_url=$/, output)
  end

  def test_completes_task_name_even_without_run_command
    output, _stderr = in_temp_dir do
      tomo "init"
      tomo "--complete-word", "rails:"
    end

    assert_match(/^console $/, output)
    assert_match(/^db_migrate $/, output)
  end

  private

  def tomo(*args)
    capturing_logger_output do
      handling_exit do
        Tomo::CLI.new.call(args.flatten)
      end
    end
  ensure
    Tomo.debug = false
    Tomo.dry_run = false
    Tomo::CLI.show_backtrace = false
    Tomo::CLI::Completions.instance_variable_set(:@active, false)
  end

  def handling_exit
    yield
  rescue Tomo::Testing::MockedExitError => e
    raise unless e.success?
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
