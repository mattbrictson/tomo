module Jam::Plugins::Core
  class Tasks
    include Jam::DSL

    def symlink_shared_directories
      return if linked_dirs.empty?

      remote.mkdir_p(*linked_dir_parents) unless linked_dir_parents.empty?
      linked_dirs.each do |dir|
        remote.ln_sf paths.shared.join(dir), paths.release.join(dir)
      end
    end

    def symlink_current
      remote.ln_sf paths.release, paths.current
    end

    private

    def linked_dirs
      settings[:linked_dirs]
    end

    def linked_dir_parents
      parents = linked_dirs.map do |dir|
        paths.release.join(dir).dirname
      end
      parents = parents.uniq - [paths.release]
    end
  end
end
