# run

Run a specific remote task from the current project.

## Usage

```plain
$ tomo run [--dry-run] [options] [--] TASK [ARGS...]
```

Remotely run one specified TASK, optionally passing ARGS to that task. For example, if this project uses the [rails plugin](../plugins/rails.md), you could run:

```plain
$ tomo run -- rails:console --sandbox
```

This will run the [rails:console](../plugins/rails.md#railsconsole) task on the host specified in `.tomo/config.rb` [configuration file](../configuration.md), and will pass the `--sandbox` argument to that task. The `--` is used to separate tomo options from options that are passed to the task. If a task does not accept options, the `--` can be omitted, like this:

```plain
$ tomo run core:clean_releases
```

You can run any task defined by plugins loaded by the [plugin](../configuration.md#pluginname_or_relative_path) declarations in `.tomo/config.rb`. To see a list of available tasks, run the [tasks](tasks.md) command.

During the `run` command, tomo will initialize the `:release_path` setting to be equal to the current symlink (i.e. `/var/www/my-app/current`). This means that the task will run within the current release.

## Options

| Option | Purpose |
| ------ | ------- |
| `--[no-]privileged` | Run the task using a privileged user (e.g. root). This user is configured [per host](../configuration.md#hostaddress-4242options).|
{!deploy_options.md.include!}
{!project_options.md.include!}
{!common_options.md.include!}

## Example

Given the following configuration:

```ruby
plugin "bundler"
plugin "puma"
host "deployer@localhost", port: 32811
```

Then we could run [puma:restart](../plugins/puma.md#pumarestart) like this:

```plain
$ tomo run puma:restart
tomo run v0.1.0
→ Connecting to deployer@localhost:32811
• puma:restart
cd /var/www/rails-new/current && bundle exec pumactl --control-url tcp://127.0.0.1:9293 --control-token tomo restart
Command restart sent success
✔ Ran puma:restart on deployer@localhost:32811
```
