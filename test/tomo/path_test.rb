# frozen_string_literal: true

require "test_helper"

class Tomo::PathTest < Minitest::Test
  def test_join
    path = Tomo::Path.new("/some/path").join("tmp/file.txt")

    assert_kind_of(Tomo::Path, path)
    assert_equal("/some/path/tmp/file.txt", path.to_s)
  end

  def test_dirname
    path = Tomo::Path.new("/root/tmp/file.txt").dirname

    assert_kind_of(Tomo::Path, path)
    assert_equal("/root/tmp", path.to_s)
  end
end
