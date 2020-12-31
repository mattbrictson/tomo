require_relative "core/helpers"
require_relative "core/tasks"

module Tomo::Plugin
  module Core
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Core::Helpers
    tasks Tomo::Plugin::Core::Tasks

    defaults Tomo::SSH::Options::DEFAULTS.merge(
      application:           "default",
      concurrency:           10,
      current_path:          "%{deploy_to}/current",
      deploy_to:             "/var/www/%{application}",
      keep_releases:         10,
      linked_dirs:           [],
      linked_files:          [],
      local_user:            nil, # determined at runtime
      release_json_path:     "%{release_path}/.tomo_release.json",
      releases_path:         "%{deploy_to}/releases",
      revision_log_path:     "%{deploy_to}/revisions.log",
      shared_path:           "%{deploy_to}/shared",
      tmp_path:              "/tmp/tomo-#{SecureRandom.alphanumeric(8)}",
      tomo_config_file_path: nil, # determined at runtime
      run_args:              [] # determined at runtime
    )
  end
end
