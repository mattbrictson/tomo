require_relative "core/helpers"
require_relative "core/tasks"

module Tomo::Plugin
  module Core
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Core::Helpers
    tasks Tomo::Plugin::Core::Tasks

    defaults application:                  "default",
             concurrency:                  10,
             current_path:                 "%<deploy_to>/current",
             deploy_to:                    "/var/www/%<application>",
             keep_releases:                10,
             linked_dirs:                  [],
             linked_files:                 [],
             release_json_path:            "%<release_path>/.tomo_release.json",
             releases_path:                "%<deploy_to>/releases",
             revision_log_path:            "%<deploy_to>/revisions.log",
             shared_path:                  "%<deploy_to>/shared",
             tmp_path:                     "/tmp/tomo",
             run_args:                     [],
             ssh_connect_timeout:          5,
             ssh_executable:               "ssh",
             ssh_extra_opts:               %w[-o PasswordAuthentication=no],
             ssh_forward_agent:            true,
             ssh_reuse_connections:        true,
             ssh_strict_host_key_checking: "accept-new"
  end
end
