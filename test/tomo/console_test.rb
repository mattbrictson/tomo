# frozen_string_literal: true

require "stringio"

class Tomo::ConsoleTest < TomoTest
  def test_interactive_is_true_for_tty
    assert_predicate Tomo::Console.new({}, tty), :interactive?
  end

  def test_interactive_is_false_for_ci_env
    refute_predicate Tomo::Console.new({ "CIRCLECI" => "1" }, tty), :interactive?
  end

  def test_interactive_is_false_non_tty
    refute_predicate Tomo::Console.new({}, non_tty), :interactive?
  end

  def test_prompt_answer_does_not_contain_newline
    stdout = StringIO.new
    console = Tomo::Console.new({}, tty("yes\n"), stdout)
    answer = console.prompt("Are you sure? ")
    assert_equal("Are you sure? ", stdout.string)
    assert_equal("yes", answer)
  end

  def test_prompt_raises_if_not_tty
    console = Tomo::Console.new({}, non_tty("yes\n"))
    error = assert_raises(Tomo::Console::NonInteractiveError) { console.prompt("Are you sure? ") }
    assert_match(/requires an interactive console/i, error.to_console)
  end

  def test_prompt_raises_if_ci
    console = Tomo::Console.new({ "CIRCLECI" => "1" }, tty("yes\n"))
    error = assert_raises(Tomo::Console::NonInteractiveError) { console.prompt("Are you sure? ") }
    assert_match(/appears to be a non-interactive CI environment/i, error.to_console)
  end

  def test_menu_raises_if_not_tty
    console = Tomo::Console.new({}, non_tty("yes\n"))
    error = assert_raises(Tomo::Console::NonInteractiveError) { console.menu("Are you sure? ", choices: %w[y n]) }
    assert_match(/requires an interactive console/i, error.to_console)
  end

  def test_menu_raises_if_ci
    console = Tomo::Console.new({ "CIRCLECI" => "1" }, tty("yes\n"))
    error = assert_raises(Tomo::Console::NonInteractiveError) { console.menu("Are you sure? ", choices: %w[y n]) }
    assert_match(/appears to be a non-interactive CI environment/i, error.to_console)
  end

  private

  def tty(data="")
    StringIO.new(data).tap do |io|
      def io.raw
      end

      def io.tty?
        true
      end
    end
  end

  def non_tty(data="")
    StringIO.new(data)
  end
end
