# frozen_string_literal: true

require "test_helper"

class Tomo::LoggerTest < Minitest::Test
  def setup
    @stdout_io = StringIO.new
    @stderr_io = StringIO.new
    @logger = Tomo::Logger.new(stdout: @stdout_io, stderr: @stderr_io)
  end

  def teardown
    # Restore defaults
    Tomo.debug = false
    Tomo.quiet = false
  end

  def test_quiet_mode_silences_info
    Tomo.quiet = true
    @logger.info("testing")

    assert_empty(stdout)
    assert_empty(stderr)
  end

  def test_quiet_mode_doesnt_silence_error
    Tomo.quiet = true
    @logger.error("testing")

    assert_equal("  \n  ERROR: testing\n  \n", stderr)
  end

  def test_quiet_mode_doesnt_silence_warn
    Tomo.quiet = true
    @logger.warn("testing")

    assert_equal("WARNING: testing\n", stderr)
  end

  def test_quiet_mode_doesnt_silence_debug
    Tomo.debug = true
    Tomo.quiet = true
    @logger.debug("testing")

    assert_equal("DEBUG: testing\n", stderr)
  end

  private

  def stdout
    @stdout_io.string
  end

  def stderr
    @stderr_io.string
  end
end
