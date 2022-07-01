require "shellwords"
require "time"

module Tomo::Plugin::Git
  class Tasks < Tomo::TaskLibrary
    def config
      user_name = settings[:git_user_name] || remote.host.user
      user_email = settings[:git_user_email] || "#{remote.host.user}@example.com"

      remote.git("config", "--global", "user.name", user_name)
      remote.git("config", "--global", "user.email", user_email)
    end

    def clone
      require_setting :git_url

      if remote.directory?(paths.git_repo) && !dry_run?
        set_origin_url
      else
        remote.mkdir_p(paths.git_repo.dirname)
        remote.git("clone", "--mirror", settings[:git_url], paths.git_repo)
      end
    end

    def create_release # rubocop:disable Metrics/AbcSize
      remote.chdir(paths.git_repo) do
        remote.git("remote update --prune")
      end

      store_release_info
      configure_git_attributes
      remote.mkdir_p(paths.release)

      remote.chdir(paths.git_repo) do
        remote.git("archive #{ref.shellescape} | tar -x -f - -C #{paths.release.shellescape}")
      end
    end

    private

    def ref
      require_setting :git_ref if settings[:git_branch].nil?

      warn_if_ref_overrides_branch
      settings[:git_ref] || settings[:git_branch]
    end

    def warn_if_ref_overrides_branch
      return if defined?(@ref_override_warning)
      return unless settings[:git_ref] && settings[:git_branch]

      logger.warn(
        ":git_ref (#{settings[:git_ref]}) and " \
        ":git_branch (#{settings[:git_branch]}) are both specified. " \
        "Ignoring :git_branch."
      )
      @ref_override_warning = true
    end

    def set_origin_url
      remote.chdir(paths.git_repo) do
        remote.git("remote", "set-url", "origin", settings[:git_url])
      end
    end

    def configure_git_attributes
      exclusions = settings[:git_exclusions] || []
      attributes = exclusions.map { |excl| "#{excl} export-ignore" }.join("\n")

      remote.write(text: attributes, to: paths.git_repo.join("info/attributes"))
    end

    def store_release_info # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      log = remote.chdir(paths.git_repo) do
        remote.git(
          %Q(log -n1 --date=iso --pretty=format:"%H/%cd/%ae" #{ref.shellescape} --),
          silent: true
        ).stdout.strip
      end

      sha, date, email = log.split("/", 3)
      remote.release[:branch] = ref if ref == settings[:git_branch]
      remote.release[:ref] = ref
      remote.release[:author] = email
      remote.release[:revision] = sha
      remote.release[:revision_date] = date
      remote.release[:deploy_date] = Time.now.to_s
      remote.release[:deploy_user] = settings.fetch(:local_user)
    end
  end
end
