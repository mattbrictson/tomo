module Tomo::Plugin::Rails
  class Tasks < Tomo::TaskLibrary
    def assets_precompile
      remote.rake("assets:precompile")
    end

    def console
      remote.rails("console", settings[:run_args], attach: true)
    end

    def db_console
      remote.rails("dbconsole", "--include-password", settings[:run_args], attach: true)
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
      if !schema_rb_present?
        logger.warn "db/schema.rb is not present; skipping schema:load."
      elsif database_schema_loaded?
        logger.info "Database schema already loaded; skipping db:schema:load."
      else
        remote.rake("db:schema:load")
      end
    end

    def db_structure_load
      if !structure_sql_present?
        logger.warn "db/structure.sql is not present; skipping db:structure:load."
      elsif database_schema_loaded?
        logger.info "Database structure already loaded; skipping db:structure:load."
      else
        remote.rake("db:structure:load")
      end
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

    def schema_rb_present?
      remote.file?(paths.release.join("db/schema.rb"))
    end

    def structure_sql_present?
      remote.file?(paths.release.join("db/structure.sql"))
    end
  end
end
