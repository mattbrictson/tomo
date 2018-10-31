module Jam::Plugins::Rails
  class Tasks
    include Jam::DSL

    def assets_precompile
      remote.rake("assets:precompile")
    end

    def console
      remote.rails("console", settings[:run_args], attach: true)
    end

    def db_migrate
      remote.rake("db:migrate")
    end

    def db_seed
      remote.rake("db:seed")
    end
  end
end
