require_relative "helpers"
require_relative "tasks"

module Jam::Plugins::Git
  module Plugin
    extend Jam::Plugin

    helpers Jam::Plugins::Git::Helpers
    tasks Jam::Plugins::Git::Tasks

    # rubocop:disable Metrics/LineLength
    defaults git_branch:    "master",
             git_repo_path: "%<deploy_to>/repo",
             git_env:       { GIT_SSH_COMMAND: "ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no" },
             git_url:       nil
    # rubocop:enable Metrics/LineLength
  end
end
