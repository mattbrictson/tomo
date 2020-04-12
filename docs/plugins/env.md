# env

The env plugin manages environment variables on the remote host. It does this by creating an `envrc` file on the remote host and modifying the `.bashrc` of the deploy user so that the envrc is always loaded (for both interactive and non-interactive SSH sessions). There are two ways to specify the environment variables that are stored in the envrc file:

1. Use [env:set](#envset) via the command line like `tomo run env:set NAME[=VALUE] ...` to explicitly set or modify environment variables
2. Specify the `:env_vars` setting in the tomo configuration and then run the [env:update](#envupdate) task

Note that in order for these tasks to work, you must first run [env:setup](#envsetup) to ensure the deploy user's `.bashrc` is properly configured to read from the envrc file that is managed by this plugin.

## Settings

| Name          | Purpose                                                                                                                           | Default                |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `bashrc_path` | Location of the deploy user’s `.bashrc` file                                                                                      | `".bashrc"`            |
| `env_path`    | Location of the envrc file on the remote host                                                                                     | `"%{deploy_to}/envrc"` |
| `env_vars`    | A hash of environment variable names and values that will configured on the remote host; see [env:update](#envupdate) for details | `{}`                   |

## Tasks

### env:setup

Performs an [env:update](#envupdate) and then modifies the deploy user's bashrc so that the envrc is automatically loaded for all future SSH sessions. Specifically, this is what is added to the _top_ of the `.bashrc` file:

```sh
if [ -f /var/www/my-app/envrc ]; then
  . /var/www/my-app/envrc
fi
```

`env:setup` is intended for use as a [setup](../commands/setup.md) task. It must be run before other env tasks.

### env:update

Ensures that all environment variables that are specified in the `:env_vars` setting are present in the envrc file on the remote host, modifying the envrc file if necessary. For example, given this config:

```ruby
set env_vars: { RAILS_ENV: "production", PUMA_THREADS: 20 }
```

This task will ensure that the envrc file is updated to include:

```bash
export RAILS_ENV=production
export PUMA_THREADS=20
```

For environment variables that are used for secrets or other sensitive data, you can specify `:prompt` instead of the actual value. In this case tomo will prompt interactively for the value the first time it is needed. For example:

```ruby
set env_vars: { SECRET_KEY_BASE: :prompt }
```

The first time `env:update` is run, tomo will prompt for the value:

```
$ tomo deploy
tomo deploy v1.0.0
→ Connecting to user@app.example.com
• env:update
SECRET_KEY_BASE?
```

Once the environment variable exists in the envrc file, tomo will no longer prompt for it.

`env:update` is intended for use as a [deploy](../commands/deploy.md) task. It should be run at the beginning of a deploy to ensure that the environment has all the latest values before other tasks are run.

### env:set

Set one or more environment variables in the remote envrc file. This task is intended for use with [run](../commands/run.md) and takes command-line arguments. There are two forms:

```sh
# Set the remote envrc var named KEY to have VALUE
$ tomo run env:set KEY=VALUE
```

```sh
# Prompt interactively for the value of KEY and then set it in the remote envrc
$ tomo run env:set KEY
KEY?
```

### env:unset

Remove one or more environment variables from the remote envrc file. This task is intended for use with [run](../commands/run.md) and takes command-line arguments.

```sh
# Remove the remote envrc var named KEY
$ tomo run env:unset KEY
```

### env:show

Display the contents of the remote envrc file. This task is intended for use with [run](../commands/run.md).

```plain
$ tomo run env:show
tomo run v1.0.0
→ Connecting to deployer@app.example.com
• env:show
RAILS_ENV=production
SECRET_KEY_BASE=02d587d76e80b2266289adef13fc045dd8387ede92935bcc1d49aa89932e5f74c35ed25bbdc41d3cf6cfc7f5f7f1736199997be459251aec52e42797c5140743
✔ Ran env:show on deployer@app.example.com
```
