require "shellwords"
require "time"

module Tomo::Plugins::Git
  class Tasks < Tomo::TaskLibrary
    # rubocop:disable Metrics/AbcSize
    def clone
      return if remote.directory?(paths.git_repo) && !dry_run?
      raise "The git_url setting is required" unless settings[:git_url]

      remote.mkdir_p(paths.git_repo.dirname)
      remote.git("clone --mirror #{settings[:git_url]} #{paths.git_repo}")
    end

    def create_release
      remote.chdir(paths.git_repo) do
        remote.git("remote update --prune")
        remote.mkdir_p(paths.release)
        remote.git("archive #{branch} | tar -x -f - -C #{paths.release}")
      end
      store_release_info
    end
    # rubocop:enable Metrics/AbcSize

    private

    def branch
      settings[:git_branch]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def store_release_info
      log = remote.chdir(paths.git_repo) do
        remote.capture(
          %Q(git log -n1 --date=iso --pretty=format:"%H/%cd/%ae" #{branch})
        ).strip
      end

      sha, date, email = log.split("/", 3)
      remote.release[:branch] = branch
      remote.release[:author] = email
      remote.release[:revision] = sha
      remote.release[:revision_date] = date
      remote.release[:deploy_date] = settings[:start_time].to_s
      remote.release[:deploy_user] = ENV["USER"] || ENV["USERNAME"]
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
