module Tomo::Plugin::Rails
  class Tasks < Tomo::TaskLibrary
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

    def db_create
      db_task_unless_exists("db:create")
    end

    def db_setup
      db_task_unless_exists("db:setup")
    end

    def log_tail
      log_path = paths.release.join("log/${RAILS_ENV}.log")
      remote.run("tail", settings[:run_args], log_path)
    end

    private

    def db_task_unless_exists(rake_task)
      if remote.rake?("db:version", silent: true) && !dry_run?
        logger.info "Database exists; skipping #{rake_task}."
        return
      end

      remote.rake(rake_task)
    end
  end
end
