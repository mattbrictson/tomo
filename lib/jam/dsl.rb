module Jam
  module DSL
    def dry_run?
    end

    def logger
    end

    def paths
    end

    def remote
      Jam.framework.current_remote
    end

    def settings
    end
  end
end
