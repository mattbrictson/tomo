require_relative "helpers"
require_relative "tasks"

module Tomo::Plugins::Git
  module Plugin
    extend Tomo::Plugin

    helpers Tomo::Plugins::Git::Helpers
    tasks Tomo::Plugins::Git::Tasks

    # rubocop:disable Metrics/LineLength
    defaults git_branch:    "master",
             git_repo_path: "%<deploy_to>/repo",
             git_env:       { GIT_SSH_COMMAND: "ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no" },
             git_url:       nil
    # rubocop:enable Metrics/LineLength
  end
end
