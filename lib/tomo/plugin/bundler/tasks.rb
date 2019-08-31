require "yaml"

module Tomo::Plugin::Bundler
  class Tasks < Tomo::TaskLibrary
    CONFIG_SETTINGS = %i[
      bundler_deployment
      bundler_gemfile
      bundler_jobs
      bundler_path
      bundler_retry
      bundler_with
      bundler_without
    ].freeze
    private_constant :CONFIG_SETTINGS

    def config
      configuration = settings_to_configuration
      remote.mkdir_p paths.bundler_config.dirname
      remote.write(text: YAML.dump(configuration), to: paths.bundler_config)
    end

    def install
      return if remote.bundle?("check") && !dry_run?

      remote.bundle("install")
    end

    def clean
      remote.bundle("clean")
    end

    def upgrade_bundler
      needed_bundler_ver = version_setting || extract_bundler_ver_from_lockfile
      return if needed_bundler_ver.nil?

      remote.run(
        "gem", "install", "bundler",
        "--conservative", "--no-document",
        "-v", needed_bundler_ver
      )
    end

    private

    def settings_to_configuration
      CONFIG_SETTINGS.each_with_object({}) do |key, config|
        next if settings[key].nil?

        entry_key = "BUNDLE_#{key.to_s.sub(/^bundler_/, '').upcase}"
        entry_value = settings.fetch(key)
        entry_value = entry_value.join(":") if entry_value.is_a?(Array)
        config[entry_key] = entry_value.to_s
      end
    end

    def version_setting
      settings[:bundler_version]
    end

    def extract_bundler_ver_from_lockfile
      lockfile_tail = remote.capture(
        "tail", "-n", "10", paths.release.join("Gemfile.lock"),
        raise_on_error: false
      )
      lockfile_tail[/BUNDLED WITH\n   (\S+)$/, 1]
    end
  end
end
