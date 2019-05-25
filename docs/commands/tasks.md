# tasks

List all tasks that can be used with the [run](run.md) command.

## Usage

```sh
$ tomo tasks
```

List all tomo tasks (i.e. those that can be used with [`tomo run`](run.md)). Available tasks are those defined by plugins loaded in `.tomo/config.rb`. Refer to the [Configuration](../configuration.md#pluginname_or_relative_path) guide for an explanation of how plugins are loaded. The reference documentation for each plugin (e.g. [core](../plugins/core.md), [git](../plugins/git.md)) describes the tasks these plugins provide.

## Options

| Option | Purpose |
| ------ | ------- |
{!common_options.md.include!}

## Example

```plain
$ tomo tasks
bundler:clean
bundler:install
bundler:upgrade_bundler
core:clean_releases
core:log_revision
core:setup_directories
core:symlink_current
core:symlink_shared
core:write_release_json
env:set
env:setup
env:show
env:unset
env:update
git:clone
git:create_release
nvm:install
puma:restart
rails:assets_precompile
rails:console
rails:db_create
rails:db_migrate
rails:db_schema_load
rails:db_seed
rails:db_setup
rails:db_structure_load
rails:log_tail
rbenv:install
```
