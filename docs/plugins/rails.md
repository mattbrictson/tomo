# rails

The rails plugin provides tasks for running rails and rake commands commonly used during setup and deployment, such as for precompiling assets and migrating the database. Make sure the `RAILS_ENV` environment variable is set prior to running rails tasks. The [env plugin](env.md) is the preferred mechanism for this.

## Settings

None.

## Tasks

### rails:assets_precompile

Builds the asset pipeline in preparation for deployment. This is necessary for Rails apps that use the asset pipeline, which is all new Rails apps by default. Running this task will execute this script:

```
cd /var/www/my-app/releases/<RELEASE_NUMBER> && bundle exec rake assets:precompile
```

`rails:assets_precompile` is intended for use as a [deploy](../commands/deploy.md) task. It is typically run just prior to [core:symlink_current](core.md#coresymlink_current) to activate a new release.

### rails:console

Starts an interactive Rails console via SSH to the remote host. This task is intended for use as a [run](../commands/run.md) task and accepts command-line arguments. The arguments are passed through to the console. For example:

```
$ tomo run -- rails:console --sandbox
```

Will run this remote script:

```
cd /var/www/my-app/current && bundle exec rails console --sandbox
```

### rails:db_console

Starts an interactive database console (e.g. psql) for the primary Rails database via SSH to the remote host. This task is intended for use as a [run](../commands/run.md) task. The `include-password` option is passed automatically.

```
$ tomo run rails:db_console
```

Will run this remote script:

```
cd /var/www/my-app/current && bundle exec rails dbconsole --include-password
```

### rails:db_migrate

Migrates the database by running:

```
cd /var/www/my-app/releases/<RELEASE_NUMBER> && bundle exec rake db:migrate
```

`rails:db_migrate` is intended for use as a [deploy](../commands/deploy.md) task. It is typically run just after [bundler:install](bundler.md#bundlerinstall) prior to activating a new release.

### rails:db_seed

Loads seed data into the database. Seeds should be written to be idempotent, such that it is safe to seed the database on each deploy. Typically seeds are used to load reference data need for the app to function, or for example to create an initial admin user. This task runs the following script:

```
cd /var/www/my-app/releases/<RELEASE_NUMBER> && bundle exec rake db:seed
```

`rails:db_seed` is intended for use as a [deploy](../commands/deploy.md) task. Since seeds rely on the structure of the database, it is typically run just after [rails:db_migrate](#railsdb_migrate).

### rails:db_create

Runs `bundle exec rake db:create` to create the database. This task is intended for use as a [setup](../commands/setup.md) task. It will be automatically skipped if the database already exists, so it is safe to re-run.

### rails:db_schema_load

Runs `bundle exec rake db:schema:load` to load the schema from `db/schema.rb` into an existing database. This task is intended for use as a [setup](../commands/setup.md) task after `rails:db_create`. It will be automatically skipped if the database already contains a schema, so it is safe to re-run.

### rails:db_structure_load

Runs `bundle exec rake db:structure:load` to load the schema from `db/structure.sql` into an existing database. This task is intended for use as a [setup](../commands/setup.md) task after `rails:db_create`. It will be automatically skipped if the database already contains a schema, so it is safe to re-run.

## Helpers

These helper methods become available on instances of [Remote](../api/Remote.md) when the rails plugin is loaded. They accept the same `options` as [Remote#run](../api/Remote.md#run42command-4242options-tomoresult).

### remote.rails(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `bundle exec rails` in within `paths.release` by default.

```ruby
remote.rails("routes")
# $ cd /var/www/my-app/releases/20190604204415 && bundle exec rails routes
```

### remote.rake(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `bundle exec rake` in within `paths.release` by default.

```ruby
remote.rake("db:migrate")
# $ cd /var/www/my-app/releases/20190604204415 && bundle exec rake db:migrate
```

### remote.rake?(\*args, \*\*options) → true or false

Like `rake` but returns `true` if the command succeeds (exit status 0), otherwise `false`.

```ruby
remote.rake?("db:migrate") # => true
```

### remote.thor(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `bundle exec thor` in within `paths.release` by default.

```ruby
remote.thor("user:create")
# $ cd /var/www/my-app/releases/20190604204415 && bundle exec thor user:create
```
