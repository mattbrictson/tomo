require "test_helper"

class Tomo::TaskAPITest < Minitest::Test
  Subject = Struct.new(:context)
  Subject.include Tomo::TaskAPI

  def test_merge_template_with_absolute_path
    abs_path = File.expand_path("../fixtures/template.erb", __dir__)
    subject = configure(application: "test-app")
    merged = subject.send(:merge_template, abs_path)
    assert_equal("Hello, test-app!\n", merged)
  end

  def test_merge_template_with_path_relative_to_config
    config_path = File.expand_path("../../.tomo/config.rb", __dir__)
    rel_path = "../test/fixtures/template.erb"
    subject = configure(application: "test-app", tomo_config_file_path: config_path)
    merged = subject.send(:merge_template, rel_path)
    assert_equal("Hello, test-app!\n", merged)
  end

  def test_merge_template_raises_on_file_not_found
    subject = configure
    assert_raises(Tomo::Runtime::TemplateNotFoundError) do
      subject.send(:merge_template, "path_does_not_exist")
    end
  end

  private

  def configure(settings={})
    defaults = { tomo_config_file_path: nil }
    Subject.new(Tomo::Runtime::Context.new(defaults.merge(settings)))
  end
end
