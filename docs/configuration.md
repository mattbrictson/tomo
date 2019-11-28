# Configuration

Tomo is configured via a `.tomo/config.rb` file. This configuration file defines what tasks to run when executing a [setup](commands/setup.md) or [deploy](commands/deploy.md), the settings that affect the behavior of those tasks, and the remote host or hosts where those tasks will be run.

The format of tomo’s configuration file is designed to be simple and concise for basic deployments, with the flexibility to scale to more advanced setups that involve multiple roles, environments, and hosts.

A basic deployment will typically use these configuration directives:

- [plugin](#pluginname_or_relative_path)
- [host][]
- [set][]
- [setup][]
- [deploy][]

Here's an abbreviated example:

```ruby
plugin "git"
plugin "bundler"
plugin "rails"
# ...

host "deployer@app.example.com"

set application: "my-rails-app"
set deploy_to: "/var/www/%{application}"
set git_url: "git@github.com:my-username/my-rails-app.git"
set git_branch: "master"
# ...

setup do
  run "git:clone"
  run "git:create_release"
  run "bundler:install"
  run "rails:db_schema_load"
  # ...
end

deploy do
  run "git:create_release"
  run "core:symlink_shared"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:assets_precompile"
  run "rails:db_migrate"
  run "core:symlink_current"
  # ...
end
```

A more complex deployment may make use of these additional directives:

- [environment](#environmentname-block)
- [role][]
- [batch](#batchblock)

## plugin(name_or_relative_path)

Load a tomo plugin by name or from a Ruby file by a relative path.

Several plugins are built into tomo: [bundler](plugins/bundler.md), [env](plugins/env.md), [git](plugins/git.md), [nodenv](plugins/nodenv.md), [puma](plugins/puma.md), [rails](plugins/rails.md), and [rbenv](plugins/rbenv.md). If you want to use the tasks provided by one of these plugins, load it by name, like this:

```ruby
plugin "git"
```

Plugins can also be provided by gems installed on your system. For example, the `tomo-plugin-sidekiq` gem provides the "sidekiq" plugin. Make sure the gem is installed (e.g. in your Gemfile) and then reference the plugin by name to load it:

```ruby
plugin "sidekiq"
```

Note that the name of the plugin may not necessarily match the name of the gem. Refer to the gem’s documentation for installation instructions.

Finally, if the argument to `plugin` starts with a dot (`.`) it is considered a relative path to a custom plugin. By convention, custom plugins are stored in `.tomo/plugins/` within the project that tomo is deploying. The name of the plugin is inferred from its file name. So for example, if the plugin is loaded from a file named `foo.rb`, then the name of the plugin is "foo" and all tasks it defines will be given the `foo:` namespace:

```ruby
plugin "./plugins/foo.rb"
```

## host(address, \*\*options)

Specify the SSH host address (including username) that tomo will connect to. For example:

```ruby
host "deployer@app.example.com" # port 22 is implied
```

```ruby
host "admin@192.168.1.50", port: 8022 # port 8022
```

The following advanced `options` are supported:

| Name              | Purpose                                                                                                                               | Default  |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `port`            | SSH port number.                                                                                                                      | `22`     |
| `roles`           | An array of String roles to assign to this host. Used with the [role][] directive for specifying which tasks should run on this host. | `[]`     |
| `log_prefix`      | A String prefix to print next to all log output for this host.                                                                        | `nil`    |
| `privileged_user` | The SSH user to connect as when running privileged tasks. See [setup][] for an example.                                               | `"root"` |

## set(hash)

Specify a value for a tomo setting. For example, to change the number of releases that tomo retains when pruning old releases:

```ruby
set keep_releases: 5
```

For a full list of settings that affect tomo’s core behavior, refer to the [core plugin documentation](plugins/core.md). Each plugin such as [bundler](plugins/bundler.md) and [git](plugins/git.md) also has its own specialized list of settings. Refer to the each plugin’s documentation for a full reference.

#### Interpolation

It is possible to reference other settings when specifying a value. The format of a reference string is `%{name}` where `name` is the name of another setting. This is often used to build paths that are relative to the release that is being deployed, or for paths relative to tomo’s shared directory.

In this example, the value will be interpolated to contain the release that is being deployed:

```ruby
set release_json_path: "%{release_path}/.tomo_release.json"
# => "/var/www/my-app/20190523234156/.tomo_release.json"
```

Another common use case is the shared directory:

```ruby
set bundler_path: "%{shared_path}/bundle"
# => "/var/www/my-app/shared/bundle"
```

Interpolation takes place after tomo has loaded all configuration, plugins, and overrides, just before tasks are run.

#### Custom settings

`set` will define a setting if it does not already exist. This means you can create arbitrarily-named settings for your own purposes, such as for use within custom tasks.

```ruby
set my_setting_i_just_made_up: "great"
```

In practice most settings are strings, but any Ruby value is possible.

```ruby
set some_double: 0.57
set my_hash: { urgent: true, message: "hello" }
```

#### Overrides

Settings defined by `set` can be overridden when running a tomo command, e.g. `tomo deploy`, by way of environment variables and command-line arguments.

Environment variable overrides take the form of `TOMO_*`. For example, this will override the `:git_branch` setting to be "develop":

```
$ export TOMO_GIT_BRANCH=develop
$ tomo deploy
```

On the command line, `-s` or `--setting` can be used. For example:

```
$ tomo deploy -s git_branch=develop
```

The precedence of overrides is as follows (higher in the list have higher precedence):

1. Command-line overrides
2. Environment variable overrides
3. `set`
4. Defaults (specified by plugins)

## setup(&block)

Define the list of tasks that will be run by the [`tomo setup`](commands/setup.md) command, by providing a block containing `run` directives, like this:

```ruby
setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:clone"
  run "git:create_release"
  run "core:symlink_shared"
  run "nodenv:install"
  run "rbenv:install"
  run "bundler:upgrade_bundler"
  run "bundler:config"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_schema_load"
  run "rails:db_seed"
  run "puma:setup_systemd"
end
```

Each `run` can optionally take a `privileged: true` option. When specified, the task will be run using the "root" user instead of the default user specified for each `host`.

```ruby
setup do
  run "apt:install", privileged: true
end
```

## deploy(&block)

Define the list of tasks that will be run by the [`tomo deploy`](commands/deploy.md) command, by providing a block containing `run` directives, like this:

```ruby
deploy do
  run "env:update"
  run "git:create_release"
  run "core:symlink_shared"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:db_migrate"
  run "rails:db_seed"
  run "rails:assets_precompile"
  run "core:symlink_current"
  run "puma:restart"
  run "puma:check_active"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
```

## environment(name, &block)

Define an environment so that tomo can be used to deploy the same project with more than one set of configuration. Each environment must have a unique name and can contain its own [host][] and [set][] directives. For example:

```ruby
# Top-level config is shared by both environments
set git_url: "git@github.com:username/repo.git"

environment :staging do
  host "deployer@staging.example.com"
  set git_branch: "develop"
end

environment :production do
  host "deployer@app.example.com"
  set git_branch: "master"
end
```

Use the `-e` or `--environment` option when running tomo to select which environment to use.

## role(name, runs:)

Specify that certain task(s) are only allowed to run on hosts that have the role `name`. The `runs` option must be an array of Strings representing task names. Simple wildcards (glob rules using `*`) can be used to match multiple tasks.

By default, every task that is listed in [setup][] and [deploy][] blocks is run on every host. In a multi-host deployment this is not always desirable. For example, the `rails:db_seed` and `rails:db_migrate` tasks should only be run once per deployment (i.e. on one host). To accomplish this, we can define a role named "db" that is responsible for running these tasks, like this:

```ruby
role "db", runs: ["rails:db_*"]
host "deployer@app1.example.com", roles: ["db"]
host "deployer@app2.example.com", roles: []
```

The `role` directive in the example above tells tomo that any task matching the glob pattern `rails:db_*` should _only_ run on hosts that are assigned the "db" role. That means that app1.example.com will run `rails:db_seed` and `rails:db_migrate`, but app2.example.com will not.

## batch(&block)

Define a group tasks to run in parallel during a multi-host deploy. This allows one host to "race ahead" of other hosts and leads to potentially faster deployments.

In a multi-host deployment, by default each task in a [setup][] and [deploy][] must complete on _all_ hosts before tomo will move onto the next task. This means a deployment is limited by its slowest host. If a task is configured via [role][] to run on only one host (e.g. `rails:db_migrate`), other hosts must wait until the task is done.

We can speed this up by using `batch`, as in this example:

```ruby
deploy do
  # All tasks in this batch must complete before tomo will move onto
  # core:symlink_current, but within the batch each host can "race ahead"
  # independently in parallel.
  batch do
    run "env:update"
    run "git:create_release"
    run "core:symlink_shared"
    run "core:write_release_json"
    run "bundler:install"
    run "rails:assets_precompile"
    run "rails:db_migrate"
  end
  # This task must complete on all hosts before moving onto the next batch.
  run "core:symlink_current"
  # The tasks within this batch can run independently in parallel on each host.
  batch do
    run "puma:restart"
    run "core:clean_releases"
    run "bundler:clean"
    run "core:log_revision"
  end
end
```

At runtime, tomo turns this configuration into an "execution plan", which you can see by passing the `--debug` option to `tomo deploy`. Here's what the execution plan might look like for the above configuration with two hosts:

```
DEBUG: Execution plan:
CONCURRENTLY (2 THREADS):
  = CONNECT deployer@app1.example.com
  = CONNECT deployer@app2.example.com
CONCURRENTLY (2 THREADS):
  = IN SEQUENCE:
      RUN env:update ON deployer@app1.example.com
      RUN git:create_release ON deployer@app1.example.com
      RUN core:symlink_shared ON deployer@app1.example.com
      RUN core:write_release_json ON deployer@app1.example.com
      RUN bundler:install ON deployer@app1.example.com
      RUN rails:assets_precompile ON deployer@app1.example.com
      RUN rails:db_migrate ON deployer@app1.example.com
  = IN SEQUENCE:
      RUN env:update ON deployer@app2.example.com
      RUN git:create_release ON deployer@app2.example.com
      RUN core:symlink_shared ON deployer@app2.example.com
      RUN core:write_release_json ON deployer@app2.example.com
      RUN bundler:install ON deployer@app2.example.com
      RUN rails:assets_precompile ON deployer@app2.example.com
CONCURRENTLY (2 THREADS):
  = RUN core:symlink_current ON deployer@app1.example.com
  = RUN core:symlink_current ON deployer@app2.example.com
CONCURRENTLY (2 THREADS):
  = IN SEQUENCE:
      RUN puma:restart ON deployer@app1.example.com
      RUN core:clean_releases ON deployer@app1.example.com
      RUN bundler:clean ON deployer@app1.example.com
      RUN core:log_revision ON deployer@app1.example.com
  = IN SEQUENCE:
      RUN puma:restart ON deployer@app2.example.com
      RUN core:clean_releases ON deployer@app2.example.com
      RUN bundler:clean ON deployer@app2.example.com
      RUN core:log_revision ON deployer@app2.example.com
```

As we can see, `core:symlink_current` is executed at the same time on both hosts, but before and after that, the other tasks can be executed out of sync.


[deploy]: #deployblock
[host]: #hostaddress-4242options
[role]: #rolename-runs
[set]: #sethash
[setup]: #setupblock
