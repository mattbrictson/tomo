# nodenv

The nodenv plugin installs node and yarn. This allows you to deploy an app with confidence that yarn and a particular version of node will be available on the host. This plugin is strongly recommended for Rails apps, which by default use webpacker and thus require node and yarn.

## Settings

| Name                  | Purpose                                                                                                                        | Default     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| `bashrc_path`         | Location of the deploy user’s `.bashrc` file                                                                                   | `".bashrc"` |
| `nodenv_install_yarn` | Whether to install yarn globally via `npm i -g yarn`                                                                           | `true`      |
| `nodenv_node_version` | Version of node to install                                                                                                     | `nil`       |
| `nodenv_yarn_version` | A value of `nil` (the default) means install the latest; specify this only if you need a specific 1.y.z global version of yarn | `nil`       |

## Tasks

### nodenv:install

Installs nodenv, uses nodenv to install node, and makes the desired version of node the global default version for the deploy user. During installation, the user’s bashrc file is modified so that nodenv is automatically loaded for interactive and non-interactive shells.

You must supply a value for the `nodenv_node_version` setting for this task to work.

By default, yarn is also installed globally via npm. This can be disabled by setting `nodenv_install_yarn` to `false`.

`nodenv:install` is intended for use as a [setup](../commands/setup.md) task.
