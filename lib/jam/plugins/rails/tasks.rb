module Jam::Plugins::Rails
  class Tasks < Jam::TaskLibrary
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

    def log_tail
      log_path = paths.release.join("log/${RAILS_ENV}.log")
      remote.run("tail", settings[:run_args], log_path)
    end
  end
end
