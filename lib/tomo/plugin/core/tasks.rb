require "json"
require "securerandom"

module Tomo::Plugin::Core
  class Tasks < Tomo::TaskLibrary
    RELEASE_REGEXP = /\d{14}/
    private_constant :RELEASE_REGEXP

    def setup_directories
      dirs = [
        paths.deploy_to,
        paths.current.dirname,
        paths.releases,
        paths.revision_log.dirname,
        paths.shared
      ].map(&:to_s).uniq

      remote.mkdir_p(*dirs)
    end

    def symlink_shared
      return if linked_dirs.empty? && linked_files.empty?

      remote.mkdir_p(*shared_directories, *link_dirnames)
      symlink_shared_directories
      symlink_shared_files
    end

    def symlink_current
      return if paths.release == paths.current

      tmp_link = "#{paths.current}-#{SecureRandom.hex(8)}"
      remote.ln_sf paths.release, tmp_link
      remote.run "mv", "-fT", tmp_link, paths.current
    end

    def clean_releases # rubocop:disable Metrics/AbcSize
      desired_count = settings[:keep_releases].to_i
      return if desired_count < 1

      current = read_current_release

      remote.chdir(paths.releases) do
        releases = remote.list_files.grep(/^#{RELEASE_REGEXP}$/o).sort
        desired_count -= 1 if releases.delete(current)
        return if releases.length <= desired_count

        remote.rm_rf(*releases.take(releases.length - desired_count))
      end
    end

    def write_release_json
      json = JSON.pretty_generate(remote.release)
      remote.write(text: "#{json}\n", to: paths.release_json)
    end

    def log_revision # rubocop:disable Metrics/AbcSize
      ref = remote.release[:ref]
      revision = remote.release[:revision]

      message = remote.release[:deploy_date].to_s
      message << " - #{revision || '<unknown>'}"
      message << " (#{ref})" if ref && revision && !revision.start_with?(ref)
      message << " deployed by #{remote.release[:deploy_user] || '<unknown>'}"
      message << "\n"

      remote.write(text: message, to: paths.revision_log, append: true)
    end

    private

    def linked_dirs
      settings[:linked_dirs] || []
    end

    def linked_files
      settings[:linked_files] || []
    end

    def shared_directories
      result = linked_dirs.map { |name| paths.shared.join(name) }
      linked_files.each do |name|
        result << paths.shared.join(name).dirname
      end
      result.map(&:to_s).uniq - [paths.shared.to_s]
    end

    def symlink_shared_files
      return if linked_files.empty?

      linked_files.each do |file|
        remote.ln_sfn paths.shared.join(file), paths.release.join(file)
      end
    end

    def symlink_shared_directories
      return if linked_dirs.empty?

      remove_existing_link_targets
      linked_dirs.each do |dir|
        remote.ln_sf paths.shared.join(dir), paths.release.join(dir)
      end
    end

    def link_dirnames
      parents = (linked_dirs + linked_files).map do |target|
        paths.release.join(target).dirname
      end

      parents.map(&:to_s).uniq - [paths.release.to_s]
    end

    def remove_existing_link_targets
      return if linked_dirs.empty?

      remote.chdir(paths.release) do
        remote.rm_rf(*linked_dirs)
      end
    end

    def read_current_release
      result = remote.run("readlink", paths.current, raise_on_error: false, silent: true)
      return nil if result.failure?

      result.stdout.strip[%r{/(#{RELEASE_REGEXP})$}o, 1]
    end
  end
end
