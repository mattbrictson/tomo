require "test_helper"

class Tomo::ShellBuilderTest < Minitest::Test
  def test_raw_preserves_string_when_shellescaped
    raw_string = Tomo::ShellBuilder.raw("$HOME")
    assert_equal("$HOME", raw_string.shellescape)
  end

  def test_raw_works_with_frozen_strings
    raw_string = Tomo::ShellBuilder.raw("$HOME".freeze)
    assert_equal("$HOME", raw_string.shellescape)
  end
end
