# puma

The puma plugin provides basic, zero-configuration support for the default Rails web server.

## Settings

| Name                 | Purpose                                                      | Default                  |
| -------------------- | ------------------------------------------------------------ | ------------------------ |
| `puma_control_token` | Auth token to use when connecting to the puma control server | `"tomo"`                 |
| `puma_control_url`   | Connection URL for the puma control server                   | `"tcp://127.0.0.1:9293"` |

## Tasks

### puma:restart

Attempts to restart the puma web server via `pumactl`. If puma is not already running or has crashed, this task will gracefully perform a cold start of the server instead. The `puma` gem must be present in the Rails application Gemfile for this task to work. Puma is started with this command:

```
bundle exec puma --daemon
```

The `config/puma.rb` file within the Rails app is used for configuration.

`puma:restart` is intended for use in a [deploy](../commands/deploy.md), immediately following [core:symlink_current](core.md#coresymlink_current) to ensure that the new version of the Rails app is activated.
