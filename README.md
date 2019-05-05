# Tomo

[![Gem Version](https://badge.fury.io/rb/tomo.svg)](https://rubygems.org/gems/tomo)
[![Build Status](https://travis-ci.org/mattbrictson/tomo.svg?branch=master)](https://travis-ci.org/mattbrictson/tomo)
[![Code Climate](https://codeclimate.com/github/mattbrictson/tomo/badges/gpa.svg)](https://codeclimate.com/github/mattbrictson/tomo)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/mattbrictson)

Tomo is a friendly command-line tool for deploying Rails apps. It is a new alternative to Capistrano, Mina, and Shipit that optimizes for simplicity and developer happiness.

💻 Rich command-line interface with built-in bash completions<br/>
☁️ Multi-environment and role-based multi-host support<br/>
💎 Everything you need to deploy a basic Rails app out of the box<br/>
🔌 Easily extensible for polyglot projects (not just Rails!)<br/>
💡 Concise, helpful error messages<br/>
📚 Quality documentation<br/>
🔬 Minimal dependencies<br/>

This project wouldn't be possible without the generosity of the open source Ruby community. Please support open source projects and your fellow developers by helping answer questions, contributing pull requests to improve code and documentation, or just [drop a note](https://saythanks.io/to/mattbrictson) to say thanks! ❤️

---

- [Quick start](#quick-start)
- [Reference documentation](#reference-documentation) [TODO]
- [FAQ](#faq) [TODO]
- [Support](#support)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide) [TODO]

## Quick start

Tomo is distributed as a ruby gem. To install:

```
$ gem install tomo
```

#### Getting help

An easy way to kick the tires is to view the `--help`.

![$ tomo --help](./docs/_readme_images/tomo-help.png)

#### Configuring a project

Let’s init a project to see how tomo is configured.

![$ tomo init](./docs/_readme_images/tomo-init.png)

The `.tomo/config.rb` file defines all the settings and tasks needed to setup and deploy a typical Rails project. An abbreviated version looks like this:

```ruby
# .tomo/config.rb

plugin "git"
plugin "bundler"
plugin "rails"
# ...

host "user@hostname.or.ip.address"

set application: "my-rails-app"
set deploy_to: "/var/www/%<application>"
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
  run "core:symlink_shared_directories"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:assets_precompile"
  run "rails:db_migrate"
  run "core:symlink_current"
  # ...
end
```

Eventually you'll want to edit the config file to specify the appropriate user and host, perhaps define some custom tasks, and tweak the settings to make them suitable for your Rails app. You can also take advantage of more advanced features like multiple hosts and environment-based config.

#### Host setup

With tomo, an initial deployment is separated into two distinct steps. The `setup` command prepares the host for its first deploy. Let’s take a look at the documentation with `--help`:

![$ tomo setup --help](./docs/_readme_images/tomo-setup-help.png)

We can simulate the setup operation with the `--dry-run` option. Let's try it:

![$ tomo setup --dry-run](./docs/_readme_images/tomo-setup-dry-run.png)

As you can see, the setup command in this project clones the git repository, installs ruby, node, bundler, and initializes the database. One the host is set up, it is ready for its first deploy.

#### Performing a deploy

Typically you only need to run `setup` once. From then on deploying a project is a matter of running the `deploy` command.

![$ tomo deploy --help](./docs/_readme_images/tomo-deploy-help.png)

Like `setup`, this can be simulated with `--dry-run`, like this:

![$ tomo deploy --dry-run](./docs/_readme_images/tomo-deploy-dry-run.png)

#### Running a single task

Tomo can also `run` individual remote tasks. Use the `tasks` command to see the list of tasks tomo knows about.

![$ tomo tasks](./docs/_readme_images/tomo-tasks.png)

One of the built-in Rails tasks is `rails:console`, which brings up a fully-interactive Rails console over SSH. We can simulate this with `--dry-run` as well.

![$ tomo run rails:console --dry-run](./docs/_readme_images/tomo-run-rails-console-dry-run.png)

#### Writing tasks

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

![$ tomo run my-plugin:hello --dry-run](./docs/_readme_images/tomo-run-hello-dry-run.png)

#### Next steps

And just like that, you are now already familiar with the basics of tomo and how to extend it! Tomo is even more friendly and powerful with the help of bash completions. If you use bash, run `tomo completion-script` for instructions on setting them up.

To prepare your existing project for a real deploy, check out the sections of the reference documentation on configuration [TODO], writing plugins [TODO], the setup command [TODO], and the deploy command [TODO]. There is also a tutorial [TODO] that walks through deploying a new Rails app from scratch. If you have questions, check out the [FAQ](#faq) [TODO] and [support](#support) notes below. Enjoy using tomo!

## Reference documentation

[TODO]

## FAQ

[TODO]

## Support

Thanks for your interest in Tomo! I use Tomo myself to deploy my own Rails projects and intend to keep this repository working and up to date for the foreseeable future. However Tomo is only a hobby, and as the sole maintainer, my ability to provide support and review pull request is limited and a bit sporadic. My priorities right now are:

1. Improve test coverage
2. Keep the project free of any serious bugs
3. Stay up to date with the latest versions of Ruby and gem dependencies

If you'd like to help by submitting a pull request, that would be much appreciated! Check out the contribution guide to get started.

Otherwise if you want to report a bug, or have ideas, feedback or questions about Tomo, [let me know via GitHub issues](https://github.com/mattbrictson/tomo/issues/new) and I will do my best to provide a helpful answer. Happy hacking! —Matt

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of conduct

Everyone interacting in the Tomo project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattbrictson/tomo/blob/master/CODE_OF_CONDUCT.md).

## Contribution guide

[TODO]
