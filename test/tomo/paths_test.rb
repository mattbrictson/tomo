# frozen_string_literal: true

class Tomo::PathsTest < TomoTest
  def test_raises_if_setting_does_not_exist
    paths = Tomo::Paths.new({})
    assert_raises(NoMethodError) { paths.storage }
  end

  def test_returns_nil_if_setting_is_nil
    paths = Tomo::Paths.new(storage_path: nil)
    assert_nil(paths.storage)
  end
end
