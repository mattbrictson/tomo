require_relative "git/helpers"
require_relative "git/tasks"

module Tomo::Plugin
  module Git
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Git::Helpers
    tasks Tomo::Plugin::Git::Tasks
    defaults git_branch:     nil,
             git_repo_path:  "%{deploy_to}/git_repo",
             git_exclusions: [],
             git_env:        { GIT_SSH_COMMAND: "ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no" },
             git_ref:        nil,
             git_url:        nil,
             git_user_name:  nil,
             git_user_email: nil
  end
end
