require_relative "git/helpers"
require_relative "git/tasks"

module Tomo::Plugin
  module Git
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Git::Helpers
    tasks Tomo::Plugin::Git::Tasks

    # rubocop:disable Metrics/LineLength
    defaults git_branch:     "master",
             git_repo_path:  "%<deploy_to>/git_repo",
             git_exclusions: [],
             git_env:        { GIT_SSH_COMMAND: "ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no" },
             git_url:        nil
    # rubocop:enable Metrics/LineLength
  end
end
