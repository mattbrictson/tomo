require "shellwords"

module Jam::Plugins::Git
  class Tasks
    include Jam::DSL

    # rubocop:disable Metrics/AbcSize
    def create_release
      remote.chdir(paths.git_repo) do
        remote.run("git remote update --prune")
        @sha = remote.capture("git rev-list --max-count=1 #{branch}").strip
        remote.mkdir_p(paths.release)
        remote.run("echo #{sha} > #{paths.release.join('REVISION')}")
        remote.run("git archive #{branch} | tar -x -f - -C #{paths.release}")
      end
    end
    # rubocop:enable Metrics/AbcSize

    def log_revision
      user = ENV["USER"]
      message = "Branch #{branch} (at #{sha}) deployed by #{user}"
      remote.run "echo #{message.shellescape} >> #{paths.revision_log}"
    end

    private

    attr_reader :sha

    def branch
      settings[:git_branch]
    end
  end
end
