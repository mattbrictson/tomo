# bundler

The bundler plugin installs ruby gem dependencies using bundler. This is required for deploying Rails apps. It also provides conveniences for using `bundle exec`.

## Settings

Note that the settings listed here only take effect if you run the [bundler:config](#bundlerconfig) task.

| Name                  | Purpose                                                                                                                                                                       | Default                   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `bundler_config_path` | Location where the [bundler:config](#bundlerconfig) task will write bundler's configuration file                                                                              | `".bundle/config"`        |
| `bundler_deployment`  | Enables bundler's [deployment mode](https://bundler.io/v2.0/man/bundle-install.1.html#DEPLOYMENT-MODE) (strongly recommended)                                                 | `true`                    |
| `bundler_gemfile`     | Optionally used to override the location of the Gemfile                                                                                                                       | `nil`                     |
| `bundler_jobs`        | Override bundler's default (number of processors) amount of concurrency used when downloading/installing gems                                                                 | `nil`                     |
| `bundler_path`        | Directory where gems where be installed                                                                                                                                       | `"%{shared_path}/bundle"` |
| `bundler_retry`       | Number of times to retry installing a gem if it fails to download                                                                                                             | `"3"`                     |
| `bundler_version`     | The version of bundler to install, used by the [bundler:upgrade_bundler](#bundlerupgrade_bundler) task; if `nil` (the default), determine the version based on `Gemfile.lock` | `nil`                     |
| `bundler_without`     | Array of Gemfile groups to exclude from installation                                                                                                                          | `["development", "test"]` |

## Tasks

### bundler:upgrade_bundler

Installs the version of bundler specified by the `:bundler_version` setting, if specified. If `:bundler_version` is `nil` (the default), this task will automatically determine the version of bundler required by the app that is being deployed by looking at the `BUNDLED WITH` entry within the app’s `Gemfile.lock`. Bundler will be installed withing this command:

```
gem install bundler --conservative --no-document -v VERSION
```

`bundler:upgrade_bundler` is intended for use as a [setup](../commands/setup.md) task. It should be run prior to [bundler:install](#bundlerinstall) to ensure that the correct version bundler is present.

### bundler:config

Writes a `.bundle/config` file with the configuration specified by the various `:bundler_*` tomo settings. This ensures that invocations of `bundle check`, `bundle install`, and most importantly `bundle exec` all consistently use the correct bundler configuration.

`bundler:config` is intended for use as a [setup](../commands/setup.md) task. It should be run prior to [bundler:install](#bundlerinstall) so that gems are installed in the proper location.

### bundler:install

Runs `bundle install` to download and install all the dependencies specified by the Gemfile of the app that is being deployed. As a performance optimization, this task will run `bundle check` first to see if the app’s dependencies have already been installed. If so, `bundle install` is skipped.

`bundler:install` is intended for use as a [deploy](../commands/deploy.md) task. It should be run prior to any tasks that rely on gems.

### bundler:clean

Runs `bundle clean` to delete any previously installed gems that are no longer needed by the current version of the app. Cleaning is generally good practice to save disk space and speed up app launch time.

`bundler:clean` is intended for use as a [deploy](../commands/deploy.md) task. It should be run at the conclusion of the deploy after all other tasks.

## Helpers

These helper methods become available on instances of [Remote](../api/Remote.md) when the bundler plugin is loaded. They accept the same `options` as [Remote#run](../api/Remote.md#run42command-4242options-tomoresult).

### remote.bundle(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `bundle` within `release_path` by default.

```ruby
remote.bundle("exec", "rails", "console")
# $ cd /var/www/my-app/current && bundle exec rails console
```

### remote.bundle?(\*args, \*\*options) → true or false

Same as `bundle` but returns `true` if the command succeeded, `false` otherwise.
