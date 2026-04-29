# frozen_string_literal: true

module Tomo::Plugin::Direct
  class Tasks < Tomo::TaskLibrary
    DEFAULT_EXCLUSIONS = %w[
      .git
      .gitignore
      .tomo
      node_modules
      tmp
      log
      .bundle
      vendor/bundle
      *.log
      .env
      .env.*
      .DS_Store
    ].freeze

    def create_release
      remote.mkdir_p(paths.release)
      store_release_info
      remote.upload_archive(
        source_path: resolve_source_path,
        destination_path: paths.release,
        exclusions: all_exclusions
      )
    end

    private

    def resolve_source_path
      configured_path = settings[:direct_source_path]
      return configured_path if configured_path

      paths.tomo_config_file&.dirname&.dirname&.to_s || Dir.pwd
    end

    def all_exclusions
      settings[:direct_exclusions] || DEFAULT_EXCLUSIONS
    end

    def store_release_info
      remote.release[:deploy_date] = Time.now.to_s
      remote.release[:deploy_user] = settings.fetch(:local_user)
      remote.release[:source_path] = resolve_source_path
    end
  end
end
