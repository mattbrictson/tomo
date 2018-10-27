require_relative "helpers"

module Jam
  module Plugins
    module Core
      module Plugin
        extend Jam::Plugin

        helpers Jam::Plugins::Core::Helpers

        defaults application:   "default",
                 deploy_to:     "/var/www/%<application>",
                 current_path:  "%<deploy_to>/current",
                 release_path:  "%<current_path>",
                 releases_path: "%<deploy_to>/releases",
                 shared_path:   "%<deploy_to>/shared",
                 repo_path:     "%<deploy_to>/repo"
      end
    end
  end
end
