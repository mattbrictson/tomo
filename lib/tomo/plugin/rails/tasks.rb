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
      return remote.rake("db:create") unless database_exists?

      logger.info "Database already exists; skipping db:create."
    end

    def db_setup
      return remote.rake("db:setup") unless database_exists?

      logger.info "Database already exists; skipping db:setup."
    end

    def db_schema_load
      return remote.rake("db:schema:load") unless database_schema_loaded?

      logger.info "Database schema already loaded; skipping db:schema:load."
    end

    def db_structure_load
      return remote.rake("db:structure:load") unless database_schema_loaded?

      logger.info "Database structure already loaded; "\
                  "skipping db:structure:load."
    end

    def log_tail
      log_path = paths.release.join("log/${RAILS_ENV}.log")
      remote.run("tail", settings[:run_args], log_path)
    end

    private

    def database_exists?
      remote.rake?("db:version", silent: true) && !dry_run?
    end

    def database_schema_loaded?
      result = remote.rake("db:version", silent: true, raise_on_error: false)
      schema_version = result.output[/version:\s*(\d+)$/i, 1].to_i

      result.success? && schema_version.positive? && !dry_run?
    end
  end
end
