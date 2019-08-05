# nodenv

The nodenv plugin installs node and optionally yarn via nodenv. This allows you to deploy an app with confidence that particular versions of these tools will be available on the host. This plugin is strongly recommended for Rails apps, which by default use webpacker and thus require node and yarn.

## Settings

| Name                  | Purpose                                      | Default     |
| --------------------- | -------------------------------------------- | ----------- |
| `bashrc_path`         | Location of the deploy user’s `.bashrc` file | `".bashrc"` |
| `nodenv_version`      | Version of nodenv to install                 | `"0.34.0"`  |
| `nodenv_node_version` | Version of node to install                   | `nil`       |
| `nodenv_yarn_version` | Version of yarn to install                   | `nil`       |

## Tasks

### nodenv:install

Installs nodenv, uses nodenv to install node, and makes the desired version of node the global default version for the deploy user. During installation, the user’s bashrc file is modified so that nodenv is automatically loaded for interactive and non-interactive shells.

You must supply a value for the `nodenv_node_version` setting for this task to work. If the `nodenv_yarn_version` setting is specified, yarn is also installed globally via npm. This setting is optional.

`nodenv:install` is intended for use as a [setup](../commands/setup.md) task.
