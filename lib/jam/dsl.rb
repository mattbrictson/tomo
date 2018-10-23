module Jam
  module DSL
    autoload :Remote, "jam/dsl/remote"

    def dry_run?
    end

    def logger
    end

    def paths
    end

    def remote
      Framework.instance.remote
    end

    def settings
    end
  end
end
