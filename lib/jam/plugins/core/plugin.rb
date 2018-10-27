require_relative "helpers"

module Jam
  module Plugins
    module Core
      module Plugin
        extend Jam::Plugin

        helpers Jam::Plugins::Core::Helpers

        defaults application:       "default",
                 deploy_to:         "/var/www/%<application>",
                 current_path:      "%<deploy_to>/current",
                 linked_dirs:       [],
                 release_path:      "%<current_path>",
                 releases_path:     "%<deploy_to>/releases",
                 repo_path:         "%<deploy_to>/repo",
                 shared_path:       "%<deploy_to>/shared",
                 revision_log_path: "%<deploy_to>/revisions.log"

      end
    end
  end
end
