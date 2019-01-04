require "test_helper"

class TomoTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tomo::VERSION
  end
end
