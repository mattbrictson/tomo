require "test_helper"

class Tomo::ConsoleTest < Minitest::Test
  def test_interactive_is_true_for_tty
    assert Tomo::Console.new({}, tty).interactive?
  end

  def test_interactive_is_false_for_ci_env
    refute Tomo::Console.new({ "CIRCLECI" => "1" }, tty).interactive?
  end

  def test_interactive_is_false_non_tty
    refute Tomo::Console.new({}, non_tty).interactive?
  end

  def prompt_answer_does_not_contain_newline
    console = Tomo::Console.new({}, tty("yes\n"))
    answer = console.prompt("Are you sure? ")
    assert_equal("yes", answer)
  end

  def prompt_raises_if_not_tty
    console = Tomo::Console.new({}, non_tty("yes\n"))
    error = assert_raises { console.prompt("Are you sure? ") }
    assert_match(/interactive console is required/i, error.message)
  end

  def prompt_raises_if_ci
    console = Tomo::Console.new({ "CIRCLECI" => "1" }, tty("yes\n"))
    error = assert_raises { console.prompt("Are you sure? ") }
    assert_match(/appears to be a CI environment/i, error.message)
  end

  def menu_raises_if_not_tty
    console = Tomo::Console.new({}, non_tty("yes\n"))
    error = assert_raises { console.menu("Are you sure? ", choices: %w[y n]) }
    assert_match(/interactive console is required/i, error.message)
  end

  def menu_raises_if_ci
    console = Tomo::Console.new({ "CIRCLECI" => "1" }, tty("yes\n"))
    error = assert_raises { console.menu("Are you sure? ", choices: %w[y n]) }
    assert_match(/appears to be a CI environment/i, error.message)
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
