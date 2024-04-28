require "test_helper"

class Tomo::ColorsTest < Minitest::Test
  def setup
    # This forces color support detection to happen again
    Tomo::Colors.remove_instance_variable(:@enabled)
  end

  def teardown
    Tomo::Colors.enabled = false
  end

  def test_enabled_by_default_if_tty
    with_tty(true) do
      with_env({}) do
        assert_predicate(Tomo::Colors, :enabled?)
      end
    end
  end

  def test_disabled_by_default_if_not_tty
    with_tty(false) do
      with_env({}) do
        refute_predicate(Tomo::Colors, :enabled?)
      end
    end
  end

  def test_enabled_by_clicolor_force
    with_tty(false) do
      with_env("CLICOLOR_FORCE" => "1") do
        assert_predicate(Tomo::Colors, :enabled?)
      end
    end
  end

  def test_disabled_by_no_color
    with_tty(true) do
      with_env("NO_COLOR" => "1") do
        refute_predicate(Tomo::Colors, :enabled?)
      end
    end
  end

  def test_disabled_by_dumb_term
    with_tty(true) do
      with_env("TERM" => "dumb") do
        refute_predicate(Tomo::Colors, :enabled?)
      end
    end
  end

  private

  def with_tty(tty, &block)
    $stdout.stub(:tty?, tty) { $stderr.stub(:tty?, tty, &block) }
  end

  def with_env(env, &)
    ENV.stub(:[], ->(name) { env[name] }, &)
  end
end
