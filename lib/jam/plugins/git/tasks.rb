require "shellwords"

module Jam::Plugins::Git
  class Tasks < Jam::TaskLibrary
    # rubocop:disable Metrics/AbcSize
    def clone
      return if remote.directory?(paths.git_repo)
      raise "The git_url setting is required" unless settings[:git_url]

      remote.mkdir_p(paths.git_repo.dirname)
      remote.git("clone --mirror #{settings[:git_url]} #{paths.git_repo}")
    end

    def create_release
      remote.chdir(paths.git_repo) do
        remote.git("remote update --prune")
        @sha = remote.capture("git rev-list --max-count=1 #{branch}").strip
        remote.mkdir_p(paths.release)
        remote.run("echo #{sha} > #{paths.release.join('REVISION')}")
        remote.git("archive #{branch} | tar -x -f - -C #{paths.release}")
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
