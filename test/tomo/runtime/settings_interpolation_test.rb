require "test_helper"

class Tomo::Runtime::SettingsInterpolationTest < Minitest::Test
  include Tomo::Testing::LogCapturing

  def test_interpolates_settings
    interpolated = interpolate(
      application: "test",
      deploy_to: "/var/www/%{application}",
      current_path: "%{deploy_to}/current",
      application_json_path: "%{deploy_to}/%{application}.json"
    )
    assert_equal(
      {
        application: "test",
        deploy_to: "/var/www/test",
        current_path: "/var/www/test/current",
        application_json_path: "/var/www/test/test.json"
      },
      interpolated
    )
  end

  def test_raises_on_unknown_setting
    assert_raises(KeyError) do
      interpolate(deploy_to: "/var/www/%{application}")
    end
  end

  def test_raises_on_circular_dependency
    exception = assert_raises(RuntimeError) do
      interpolate(
        application: "default",
        deploy_to: "%{current_path}/%{application}",
        current_path: "%{deploy_to}/current"
      )
    end
    assert_match(
      "Circular dependency detected in settings: "\
      "deploy_to -> current_path -> deploy_to",
      exception.message
    )
  end

  def test_warns_on_old_syntax
    interpolated = capturing_logger_output do
      interpolate(application: "default", deploy_to: "/var/www/%<application>")
    end
    assert_match(<<~WARNING, stderr)
      :deploy_to is using the deprecated %<...> interpolation syntax.
        Replace:   %<application>
        with this: %{application}
      The %<...> syntax will not work in future versions of tomo.
    WARNING
    assert_equal("/var/www/default", interpolated[:deploy_to])
  end

  private

  def interpolate(settings)
    Tomo::Runtime::SettingsInterpolation.interpolate(settings)
  end
end
