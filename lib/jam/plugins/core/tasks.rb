module Jam::Plugins::Core
  class Tasks
    include Jam::DSL

    def symlink_shared_directories
      linked_dirs = settings[:linked_dirs]
      return if linked_dirs.empty?

      parents = linked_dirs.map do |dir|
        paths.release.join(dir).dirname.to_s
      end
      parents = parents.uniq - [paths.release.to_s]

      remote.mkdir_p(*parents) unless parents.empty?

      settings[:linked_dirs].each do |dir|
        remote.ln_sf paths.shared.join(dir), paths.release.join(dir)
      end
    end

    def symlink_current
      remote.ln_sf paths.release, paths.current
    end
  end
end
