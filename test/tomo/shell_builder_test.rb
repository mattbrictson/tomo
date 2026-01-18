# frozen_string_literal: true

class Tomo::ShellBuilderTest < TomoTest
  def test_raw_preserves_string_when_shellescaped
    raw_string = Tomo::ShellBuilder.raw("$HOME")
    assert_equal("$HOME", raw_string.shellescape)
  end

  def test_raw_works_with_frozen_strings
    raw_string = Tomo::ShellBuilder.raw("$HOME")
    assert_equal("$HOME", raw_string.shellescape)
  end
end
