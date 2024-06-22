# frozen_string_literal: true

require "test_helper"
require "stringio"

class Tomo::Console
  class KeyReaderTest < Minitest::Test
    def setup
      @input = StringIO.new
      @input.define_singleton_method(:raw) do |&block|
        block.call
      end
    end

    def test_reads_a_single_keystroke
      @input << "h"
      @input.rewind

      key_reader = KeyReader.new(@input)
      char = key_reader.next

      assert_equal("h", char)
    end
  end
end
