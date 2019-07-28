require "shellwords"
require "time"

module Tomo::Plugin::Git
  class Tasks < Tomo::TaskLibrary
    # rubocop:disable Metrics/AbcSize
    def clone
      require_setting :git_url

      if remote.directory?(paths.git_repo) && !dry_run?
        set_origin_url
      else
        remote.mkdir_p(paths.git_repo.dirname)
        remote.git("clone", "--mirror", settings[:git_url], paths.git_repo)
      end
    end

    def create_release
      configure_git_attributes
      remote.chdir(paths.git_repo) do
        remote.git("remote update --prune")
        remote.mkdir_p(paths.release)
        remote.git(
          "archive #{branch.shellescape} | "\
          "tar -x -f - -C #{paths.release.shellescape}"
        )
      end
      store_release_info
    end
    # rubocop:enable Metrics/AbcSize

    private

    def branch
      settings[:git_branch]
    end

    def set_origin_url
      remote.chdir(paths.git_repo) do
        remote.git("remote", "set-url", "origin", settings[:git_url])
      end
    end

    def configure_git_attributes
      exclusions = settings[:git_exclusions] || []
      attributes = exclusions.map { |excl| "#{excl} export-ignore" }.join("\n")

      remote.write(
        text: attributes,
        to: paths.git_repo.join("info/attributes")
      )
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def store_release_info
      log = remote.chdir(paths.git_repo) do
        remote.git(
          'log -n1 --date=iso --pretty=format:"%H/%cd/%ae" '\
          "#{branch.shellescape}",
          silent: true
        ).stdout.strip
      end

      sha, date, email = log.split("/", 3)
      remote.release[:branch] = branch
      remote.release[:author] = email
      remote.release[:revision] = sha
      remote.release[:revision_date] = date
      remote.release[:deploy_date] = Time.now.to_s
      remote.release[:deploy_user] = ENV["USER"] || ENV["USERNAME"]
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
