# rbenv

The rbenv plugin provides a way to install and run a desired version of ruby. This is the recommended way to manage ruby for Rails apps.

## Settings

| Name                 | Purpose                                                                                        | Default     |
| -------------------- | ---------------------------------------------------------------------------------------------- | ----------- |
| `bashrc_path`        | Location of the deploy user’s `.bashrc` file                                                   | `".bashrc"` |
| `rbenv_ruby_version` | Version of ruby to install. if nil (the default), determine the version based on .ruby-version | `nil`       |

## Tasks

### rbenv:install

Installs rbenv, uses rbenv to install ruby, and makes the desired version of ruby the global default version for the deploy user. During installation, the user’s bashrc file is modified so that rbenv is automatically loaded for interactive and non-interactive shells.

Behind the scenes, rbenv installs ruby via ruby-build, which compiles ruby from source. This means installation can take several minutes. If the desired version of ruby is already installed, the compilation step will be skipped.

You must supply a value for the `rbenv_ruby_version` setting or `.ruby-version` file for this task to work.

`rbenv:install` is intended for use as a [setup](../commands/setup.md) task.
