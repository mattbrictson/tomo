require_relative "core/helpers"
require_relative "core/tasks"

module Tomo::Plugin
  module Core
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Core::Helpers
    tasks Tomo::Plugin::Core::Tasks

    defaults application:           "default",
             concurrency:           10,
             current_path:          "%<deploy_to>/current",
             deploy_to:             "/var/www/%<application>",
             environment:           nil,
             keep_releases:         10,
             linked_dirs:           [],
             release_path:          "%<current_path>",
             release_json_path:     "%<release_path>/.tomo_release.json",
             releases_path:         "%<deploy_to>/releases",
             revision_log_path:     "%<deploy_to>/revisions.log",
             shared_path:           "%<deploy_to>/shared",
             run_args:              [],
             ssh_executable:        "ssh",
             ssh_extra_opts:        [
               "-o", "ConnectTimeout=5",
               "-o", "PasswordAuthentication=no",
               "-o", "StrictHostKeyChecking=accept-new"
             ],
             ssh_forward_agent:     true,
             ssh_reuse_connections: true
  end
end
