module Jam::Plugins::Core
  class Tasks
    include Jam::DSL

    def symlink_shared_directories
      return if linked_dirs.empty?

      create_linked_parents
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

    def create_linked_parents
      parents = linked_dirs.map do |dir|
        paths.release.join(dir).dirname
      end
      parents = parents.uniq - [paths.release]

      remote.mkdir_p(*parents) unless parents.empty?
    end
  end
end
