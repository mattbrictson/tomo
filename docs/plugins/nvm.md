# nvm

The nvm plugin installs node and optionally yarn via nvm. This allows you to deploy an app with confidence that particular versions of these tools will be available on the host. This plugin is strongly recommended for Rails apps, which by default use webpacker and thus require node and yarn.

## Settings

| Name               | Purpose                                      | Default     |
| ------------------ | -------------------------------------------- | ----------- |
| `bashrc_path`      | Location of the deploy user’s `.bashrc` file | `".bashrc"` |
| `nvm_version`      | Version of nvm to install                    | `"0.34.0"`  |
| `nvm_node_version` | Version of node to install                   | `nil`       |
| `nvm_yarn_version` | Version of yarn to install                   | `nil`       |

## Tasks

### nvm:install

Installs nvm, uses nvm to install node, and makes the desired version of node the global default version for the deploy user. During installation, the user’s bashrc file is modified so that nvm is automatically loaded for interactive and non-interactive shells.

You must supply a value for the `nvm_node_version` setting for this task to work. If the `nvm_yarn_version` setting is specified, yarn is also installed globally via npm. This setting is optional.

`nvm:install` is intended for use as a [setup](../commands/setup.md) task.
