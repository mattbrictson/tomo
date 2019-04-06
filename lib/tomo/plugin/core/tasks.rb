require "json"

module Tomo::Plugin::Core
  class Tasks < Tomo::TaskLibrary
    def create_shared_directories
      return if linked_dirs.empty?

      remote.mkdir_p(paths.shared)

      remote.chdir(paths.shared) do
        remote.mkdir_p(*linked_dirs)
      end
    end

    def symlink_shared_files
      return if linked_files.empty?

      create_linked_parents(linked_files)
      linked_files.each do |file|
        remote.ln_sfn paths.shared.join(file), paths.release.join(file)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def symlink_shared_directories
      return if linked_dirs.empty?

      create_linked_parents(linked_dirs)
      remove_existing_link_targets
      linked_dirs.each do |dir|
        remote.ln_sf paths.shared.join(dir), paths.release.join(dir)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def symlink_current
      return if paths.release == paths.current

      remote.ln_sfn paths.release, paths.current
    end

    # rubocop:disable Metrics/AbcSize
    def clean_releases
      desired_count = settings[:keep_releases].to_i
      return if desired_count < 1

      remote.chdir(paths.releases) do
        releases = remote.list_files.grep(/^\d{14}$/).sort
        return if releases.length <= desired_count

        remote.rm_rf(*releases.take(releases.length - desired_count))
      end
    end
    # rubocop:enable Metrics/AbcSize

    def write_release_json
      json = JSON.pretty_generate(remote.release)
      remote.write(text: json, to: paths.release_json)
    end

    # rubocop:disable Metrics/AbcSize
    def log_revision
      message = settings[:start_time].to_s
      message << " - #{remote.release[:revision] || '<unknown>'}"
      message << " (#{remote.release[:branch] || '<unknown>'})"
      message << " deployed by #{remote.release[:deploy_user] || '<unknown>'}"

      remote.write(text: message, to: paths.revision_log, append: true)
    end
    # rubocop:enable Metrics/AbcSize

    private

    def linked_dirs
      settings[:linked_dirs] || []
    end

    def linked_files
      settings[:linked_files] || []
    end

    def create_linked_parents(targets)
      parents = targets.map do |target|
        paths.release.join(target).dirname
      end
      parents = parents.uniq - [paths.release]

      remote.mkdir_p(*parents) unless parents.empty?
    end

    def remove_existing_link_targets
      return if linked_dirs.empty?

      remote.chdir(paths.release) do
        remote.rm_rf(*linked_dirs)
      end
    end
  end
end
