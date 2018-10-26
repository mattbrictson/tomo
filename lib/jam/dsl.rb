module Jam
  module DSL
    def dry_run?
    end

    def logger
    end

    def paths
      Jam.framework.paths
    end

    def remote
      Jam.framework.current_remote
    end

    def settings
      Jam.framework.settings
    end
  end
end
