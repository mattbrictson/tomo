require_relative "tasks"

module Jam::Plugins::Git
  module Plugin
    extend Jam::Plugin

    tasks Jam::Plugins::Git::Tasks
    defaults git_branch: "master"
  end
end
