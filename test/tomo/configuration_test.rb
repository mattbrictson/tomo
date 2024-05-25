require "test_helper"

class Tomo::ConfigurationTest < Minitest::Test
  include Tomo::Testing::Local

  def test_parses_a_config_file_that_contains_frozen_string_literals
    in_temp_dir do
      FileUtils.mkdir ".tomo"
      File.write(".tomo/config.rb", <<~CONFIG)
        # frozen_string_literal: true

        setup do
          run "nginx:setup", privileged: true
        end
      CONFIG

      parsed = Tomo::Configuration.from_config_rb

      assert_instance_of(Tomo::Configuration, parsed)
    end
  end
end
