require_relative "helpers"
require_relative "tasks"

module Jam::Plugins::Core
  module Plugin
    extend Jam::Plugin

    helpers Jam::Plugins::Core::Helpers
    tasks Jam::Plugins::Core::Tasks

    defaults application:       "default",
             deploy_to:         "/var/www/%<application>",
             current_path:      "%<deploy_to>/current",
             linked_dirs:       [],
             release_path:      "%<current_path>",
             releases_path:     "%<deploy_to>/releases",
             shared_path:       "%<deploy_to>/shared",
             revision_log_path: "%<deploy_to>/revisions.log"
  end
end
