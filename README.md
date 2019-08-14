# Tomo

[![Gem Version](https://badge.fury.io/rb/tomo.svg)](https://rubygems.org/gems/tomo)
[![Travis](https://img.shields.io/travis/mattbrictson/tomo.svg?label=travis)](https://travis-ci.org/mattbrictson/tomo)
[![Circle](https://circleci.com/gh/mattbrictson/tomo.svg?style=shield)](https://circleci.com/gh/mattbrictson/tomo)
[![Code Climate](https://codeclimate.com/github/mattbrictson/tomo/badges/gpa.svg)](https://codeclimate.com/github/mattbrictson/tomo)

Tomo is a friendly command-line tool for deploying Rails apps. It is a new alternative to Capistrano, Mina, and Shipit that aims for simplicity and developer happiness.

💻 Rich command-line interface with built-in bash completions<br/>
☁️ Multi-environment and role-based multi-host support<br/>
💎 Everything you need to deploy a basic Rails app out of the box<br/>
🔌 Easily extensible for polyglot projects (not just Rails!)<br/>
💡 Concise, helpful error messages<br/>
📚 Quality documentation<br/>
🔬 Minimal dependencies<br/>

---

- [Quick start](#quick-start)
- [Usage](#usage)
- [Tutorials](#tutorials)
- [Reference documentation](#reference-documentation)
- [FAQ](#faq)
- [Support](#support)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

Tomo is distributed as a ruby gem. To install:

```
$ gem install tomo
```

For instructions on setting up bash completions, run:

```
$ tomo completion-script
```

#### Configuring a project

Tomo is configured via a `.tomo/config.rb` file in your project. To get started, you can use `tomo init` to generate a configuration that works for a basic Rails app.

![$ tomo init](./readme_images/tomo-init.png)

An abbreviated version looks like this:

```ruby
# .tomo/config.rb

plugin "git"
plugin "bundler"
plugin "rails"
# ...

host "user@hostname.or.ip.address"

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

Check out the [configuration docs](https://tomo-deploy.com/configuration/) for a complete reference.

## Usage

Tomo gives you easy-to-use commands for three common use cases:

1. `tomo setup` prepares a remote host for its first deploy
2. `tomo deploy` performs a deployment
3. `tomo run` lets you invoke one-off tasks

### Setup

`tomo setup` prepares the remote host for its first deploy by sequentially running the
[setup](https://tomo-deploy.com/configuration#setupblock) list of tasks specified in `.tomo/config.rb`. These tasks typically create directories, initialize data stores, install prerequisite tools, and perform other one-time actions that are necessary before a deploy can take place.

Out of the box, tomo will:

- Configure necessary environment variables, like `RAILS_ENV` and `SECRET_KEY_BASE`
- Install Ruby, Bundler, Node, Yarn, and dependencies
- Create all necessary deployment directories
- Create the Rails database, load the schema, and insert seed data

### Deploy

Whereas `tomo setup` is typically run once, you can use `tomo deploy` every time you want to deploy a new version of your app. The deploy command will sequentially run the [deploy](https://tomo-deploy.com/configuration#deployblock) list of tasks specified in `.tomo/config.rb`. You can customize this list to meet the needs of your app. By default, tomo runs these tasks:

1. Create a release (using the [git:create_release](https://tomo-deploy.com/plugins/git#gitcreate_release) task)
2. Build the project (e.g. [bundler:install](https://tomo-deploy.com/plugins/bundler#bundlerinstall), [rails:assets_precompile](https://tomo-deploy.com/plugins/rails#railsassets_precompile))
3. Migrate data to the meet the requirements of the new release (e.g. [rails:db_migrate](https://tomo-deploy.com/plugins/rails#railsdb_migrate))
4. Make the new release the "current" one ([core:symlink_current](https://tomo-deploy.com/plugins/core#coresymlink_current))
5. Restart the app to use the new current release (e.g. [puma:restart](https://tomo-deploy.com/plugins/puma#pumarestart))
6. Perform any cleanup (e.g. [bundler:clean](https://tomo-deploy.com/plugins/bundler#bundlerclean))

### Run

Tomo can also `run` individual remote tasks on demand. You can use the `tasks` command to see the list of tasks tomo knows about.

![$ tomo tasks](./readme_images/tomo-tasks.png)

One of the built-in Rails tasks is `rails:console`, which brings up a fully-interactive Rails console over SSH.

![$ tomo run rails:console](./readme_images/tomo-run-rails-console.png)

### Extending tomo

Tomo has many plugins built-in, but you can easily add your own to extend tomo with custom tasks. By convention, custom plugins are stored in `.tomo/plugins/`. These plugins can define tasks as plain ruby methods. For example:

```ruby
# .tomo/plugins/my-plugin.rb

def hello
  remote.run "echo", "hello", settings[:application]
end
```

Use `remote.run` to execute shell scripts on the remote host, similar to how you would use Ruby's `system`. Project settings are accessible via `settings`, which is a plain Ruby hash.

Load your plugin in `config.rb` like this:

```ruby
# .tomo/config.rb

plugin "./plugins/my-plugin.rb"
```

And run it!

![$ tomo run my-plugin:hello](./readme_images/tomo-run-hello.png)

Read the [Writing Custom Tasks](https://tomo-deploy.com/tutorials/writing-custom-tasks/) tutorial for an in-depth guide to extending tomo.

## Tutorials

- [Deploying Rails From Scratch](https://tomo-deploy.com/tutorials/deploying-rails-from-scratch/)
- [Writing Custom Tasks](https://tomo-deploy.com/tutorials/writing-custom-tasks/)
- [Publishing a Plugin](https://tomo-deploy.com/tutorials/publishing-a-plugin/)

## Reference documentation

- [Configuration](https://tomo-deploy.com/configuration/)
- Commands
  - [init](https://tomo-deploy.com/commands/init/)
  - [setup](https://tomo-deploy.com/commands/setup/)
  - [deploy](https://tomo-deploy.com/commands/deploy/)
  - [run](https://tomo-deploy.com/commands/run/)
  - [tasks](https://tomo-deploy.com/commands/tasks/)
- Plugins
  - [core](https://tomo-deploy.com/plugins/core/)
  - [bundler](https://tomo-deploy.com/plugins/bundler/)
  - [env](https://tomo-deploy.com/plugins/env/)
  - [git](https://tomo-deploy.com/plugins/git/)
  - [nodenv](https://tomo-deploy.com/plugins/nodenv/)
  - [puma](https://tomo-deploy.com/plugins/puma/)
  - [rails](https://tomo-deploy.com/plugins/rails/)
  - [rbenv](https://tomo-deploy.com/plugins/rbenv/)
- API
  - [Host](https://tomo-deploy.com/api/Host/)
  - [Logger](https://tomo-deploy.com/api/Logger/)
  - [Paths](https://tomo-deploy.com/api/Paths/)
  - [PluginDSL](https://tomo-deploy.com/api/PluginDSL/)
  - [Remote](https://tomo-deploy.com/api/Remote/)
  - [Result](https://tomo-deploy.com/api/Result/)
  - [TaskLibrary](https://tomo-deploy.com/api/TaskLibrary/)
  - [Testing::MockPluginTester](https://tomo-deploy.com/api/testing/MockPluginTester/)
  - [Testing::DockerPluginTester](https://tomo-deploy.com/api/testing/DockerPluginTester/)

## FAQ

#### What does the `unsupported option "accept-new"` error mean?

By default, tomo uses the ["accept-new"](https://www.openssh.com/txt/release-7.6) value for the StrictHostKeyChecking option, which is supported by OpenSSH 7.6 and newer. If you are using an older version, this will cause an error. As a workaround, you can override tomo's default behavior like this:

```ruby
# Replace "accept-new" with something compatible with older versions of SSH
set ssh_strict_host_key_checking: true # or false
```

## Support

This project is a labor of love and I can only spend a few hours a week maintaining it, at most. If you'd like to help by submitting a pull request, or if you've discovered a bug that needs my attention, please let me know. Check out [CONTRIBUTING.md](https://github.com/mattbrictson/tomo/blob/master/CONTRIBUTING.md) to get started. Happy hacking! —Matt

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of conduct

Everyone interacting in the Tomo project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattbrictson/tomo/blob/master/CODE_OF_CONDUCT.md).

## Contribution guide

Interested in filing a bug report, feature request, or opening a PR? Excellent! Please read the short [CONTRIBUTING.md](https://github.com/mattbrictson/tomo/blob/master/CONTRIBUTING.md) guidelines before you dive in.
