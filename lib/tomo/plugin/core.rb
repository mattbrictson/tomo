require_relative "core/helpers"
require_relative "core/tasks"

module Tomo::Plugin
  module Core
    extend Tomo::PluginDSL

    class << self
      private

      def local_user
        ENV["USER"] || ENV["USERNAME"] || `whoami`.chomp
      rescue StandardError
        nil
      end
    end

    helpers Tomo::Plugin::Core::Helpers
    tasks Tomo::Plugin::Core::Tasks

    defaults Tomo::SSH::Options::DEFAULTS.merge(
      application:       "default",
      concurrency:       10,
      current_path:      "%<deploy_to>/current",
      deploy_to:         "/var/www/%<application>",
      keep_releases:     10,
      linked_dirs:       [],
      linked_files:      [],
      local_user:        local_user,
      release_json_path: "%<release_path>/.tomo_release.json",
      releases_path:     "%<deploy_to>/releases",
      revision_log_path: "%<deploy_to>/revisions.log",
      shared_path:       "%<deploy_to>/shared",
      tmp_path:          "/tmp/tomo",
      run_args:          []
    )
  end
end
