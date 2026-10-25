# frozen_string_literal: true

class Tomo::ConfigurationTest < Tomo::Test
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

  def test_allows_environment_to_be_marked_as_default
    in_temp_dir do
      FileUtils.mkdir ".tomo"
      File.write(".tomo/config.rb", <<~CONFIG)
        environment :production do
          host "1.1.1.1"
        end

        environment :staging, default: true do
          host "2.2.2.2"
        end
      CONFIG

      parsed = Tomo::Configuration.from_config_rb

      assert_equal "staging", parsed.default_environment_name
    end
  end

  def test_treats_single_environment_as_implicit_default
    in_temp_dir do
      FileUtils.mkdir ".tomo"
      File.write(".tomo/config.rb", <<~CONFIG)
        environment :production do
          host "1.1.1.1"
        end
      CONFIG

      parsed = Tomo::Configuration.from_config_rb

      assert_equal "production", parsed.default_environment_name
    end
  end
end
