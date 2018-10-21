require "test_helper"

class JamTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Jam::VERSION
  end
end
