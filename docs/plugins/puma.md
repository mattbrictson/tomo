# puma

The puma plugin provides a [systemd](https://en.wikipedia.org/wiki/Systemd)-based solution for starting, stopping, and restarting puma using [socket activation][socket-activation] for zero-downtime restarts. It is based on the best practices in the [official puma documentation](https://github.com/puma/puma/blob/master/docs/systemd.md).

Tomo's implementation installs puma as a _user-level_ service using `systemctl --user`. This allows puma to be installed, started, stopped, and restarted without a root user or `sudo`. However, when provisioning the host you must make sure to run the following command as root to allow the puma process to continue running even after the tomo deploy user disconnects:

```sh
# run as root
$ loginctl enable-linger <DEPLOY_USER>
```

Stdout and stderr of the puma process will be routed to syslog, as is the convention for systemd services. For Rails, it is recommended that you set `RAILS_LOG_TO_STDOUT=1` so that all Rails logs are handled this way (`tomo init` configures this by default).

The tomo puma plugin assumes that your puma server will listen on a single TCP port for HTTP (not HTTPS) traffic. In other words, HTTPS termination will be handled by e.g. Nginx or a separate load balancer.

## Settings

| Name                                 | Purpose                                                                                                                     | Default                                            |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `puma_check_timeout`                 | The number of seconds that the [puma:check_active](#pumacheck_active) task will wait for puma to respond before timing out. | `15`                                               |
| `puma_port`                          | TCP port that puma should listen on                                                                                         | `3000`                                             |
| `puma_systemd_service`               | Name of the systemd service that manages the puma server                                                                    | `"puma_%<application>.service"`                    |
| `puma_systemd_socket`                | Name of the systemd socket that is used for [socket activation][socket-activation] of the puma service                      | `"puma_%<application>.socket"`                     |
| `puma_systemd_service_path`          | Path on the remote host where the systemd puma service configuration file will be created                                   | `".config/systemd/user/%<puma_systemd_service>"`   |
| `puma_systemd_socket_path`           | Path on the remote host where the systemd puma socket configuration file will be created                                    | `".config/systemd/user/%<puma_systemd_socket>"`    |
| `puma_systemd_service_template_path` | Local path of the ERB template to use to create the the systemd puma service configuration file                             | _default template is included inside the tomo gem_ |
| `puma_systemd_socket_template_path`  | Local path of the ERB template to use to create the the systemd puma socket configuration file                              | _default template is included inside the tomo gem_ |

## Tasks

### puma:restart

Attempts to restart the puma web server via `pumactl`. If puma is not already running or has crashed, this task will gracefully perform a cold start of the server instead. The `puma` gem must be present in the Rails application Gemfile for this task to work. Puma is started with this command:

```
bundle exec puma --daemon
```

The `config/puma.rb` file within the Rails app is used for configuration.

`puma:restart` is intended for use in a [deploy](../commands/deploy.md), immediately following [core:symlink_current](core.md#coresymlink_current) to ensure that the new version of the Rails app is activated.

[socket-activation]: https://github.com/puma/puma/blob/master/docs/systemd.md#socket-activation
