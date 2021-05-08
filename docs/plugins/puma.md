# puma

The puma plugin provides a [systemd](https://en.wikipedia.org/wiki/Systemd)-based solution for starting, stopping, and restarting puma using [socket activation][socket-activation] for zero-downtime restarts. It is based on the best practices in the [official puma documentation](https://github.com/puma/puma/blob/HEAD/docs/systemd.md).

Tomo's implementation installs puma as a _user-level_ service using `systemctl --user`. This allows puma to be installed, started, stopped, and restarted without a root user or `sudo`. However, when provisioning the host you must make sure to run the following command as root to allow the puma process to continue running even after the tomo deploy user disconnects:

```sh
# run as root
$ loginctl enable-linger <DEPLOY_USER>
```

Stdout and stderr of the puma process will be routed to syslog, as is the convention for systemd services. For Rails, it is recommended that you set `RAILS_LOG_TO_STDOUT=1` so that all Rails logs are handled this way (`tomo init` configures this by default).

The tomo puma plugin assumes that your puma server will listen on a single TCP port for HTTP (not HTTPS) traffic. In other words, HTTPS termination will be handled by e.g. Nginx or a separate load balancer.

## Settings

| Name                                 | Purpose                                                                                                                     | Default                                                                                                  |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `puma_check_timeout`                 | The number of seconds that the [puma:check_active](#pumacheck_active) task will wait for puma to respond before timing out. | `15`                                                                                                     |
| `puma_host`                          | Hostname / IP address that puma should listen on                                                                            | `0.0.0.0` (set to `127.0.0.1` to accept only internal connections)                                       |
| `puma_port`                          | TCP port that puma should listen on                                                                                         | `3000`                                                                                                   |
| `puma_systemd_service`               | Name of the systemd service that manages the puma server                                                                    | `"puma_%{application}.service"`                                                                          |
| `puma_systemd_socket`                | Name of the systemd socket that is used for [socket activation][socket-activation] of the puma service                      | `"puma_%{application}.socket"`                                                                           |
| `puma_systemd_service_path`          | Path on the remote host where the systemd puma service configuration file will be created                                   | `".config/systemd/user/%{puma_systemd_service}"`                                                         |
| `puma_systemd_socket_path`           | Path on the remote host where the systemd puma socket configuration file will be created                                    | `".config/systemd/user/%{puma_systemd_socket}"`                                                          |
| `puma_systemd_service_template_path` | Local path of the ERB template to use to create the the systemd puma service configuration file                             | [service.erb](https://github.com/mattbrictson/tomo/blob/main/lib/tomo/plugin/puma/systemd/service.erb) |
| `puma_systemd_socket_template_path`  | Local path of the ERB template to use to create the the systemd puma socket configuration file                              | [socket.erb](https://github.com/mattbrictson/tomo/blob/main/lib/tomo/plugin/puma/systemd/socket.erb)   |

## Tasks

### puma:setup_systemd

Configures systemd to manage puma. This means that puma will automatically be restarted if it crashes, or if the host is rebooted. This task essentially does three things:

1. Installs a `puma.socket` systemd unit
1. Installs a `puma.service` systemd unit that depends on the socket
1. Enables these units using `systemctl --user enable`

Note that these units will be installed and run for the deploy user. You can use `:puma_systemd_socket_template_path` and `:puma_systemd_service_template_path` to provide your own templates and customize how puma and systemd are configured.

`puma:setup_systemd` is intended for use as a [setup](../commands/setup.md) task. It must be run before puma can be started during a deploy.

### puma:restart

Restarts the puma service via systemd. This starts puma if it isn't running already. The systemd socket remains running while puma itself is restarted. In other words, incoming requests will continue to connect and queue while puma restarts. This is a "zero-downtime restart".

Puma will be configured to listen on `:puma_port`, with the `config/puma.rb` file within the Rails app providing the remainder of the configuration. The default port is 3000. Puma is started using this command:

```
bundle exec --keep-file-descriptors puma -C config/puma.rb -b tcp://0.0.0.0:3000
```

`puma:restart` is intended for use in a [deploy](../commands/deploy.md), immediately following [core:symlink_current](core.md#coresymlink_current) to ensure that the new version of the Rails app is activated.

### puma:check_active

This task queries systemd and executes a `curl` test to verify that puma is active and listening on `:puma_port`. Because puma is run in the background, it is not immediately obvious after starting or restarting puma via systemd as to whether it booted successfully, or if it crashed. This is where the `puma:check_active` task can help. If puma is not working it will fail and show puma's log output for easier troubleshooting.

`puma:check_active` is intended for use as a [deploy](../commands/deploy.md) task, immediately following [puma:restart](#pumarestart) to verify that puma restarted successfully.

### puma:start

Starts the puma socket and service via systemd, if they aren't running already. Equivalent to:

```
systemctl --user start puma.socket puma.service
```

### puma:stop

Stops the puma socket and service via systemd. Equivalent to:

```
systemctl --user stop puma.socket puma.service
```

### puma:status

Reports the status of the puma socket and service via systemd. Equivalent to:

```
systemctl --user status puma.socket puma.service
```

Sample output:

```
$ tomo run puma:status
tomo run v0.10.0
→ Connecting to deployer@app.example.com
• puma:status
systemctl --user status puma_example.socket puma_example.service
● puma_example.socket - Puma HTTP Server Accept Sockets for example
   Loaded: loaded (/home/deployer/.config/systemd/user/puma_example.socket; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2019-10-24 09:41:53 UTC; 1 weeks 2 days ago
   Listen: 0.0.0.0:3000 (Stream)

● puma_example.service - Puma HTTP Server for example
   Loaded: loaded (/home/deployer/.config/systemd/user/puma_example.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2019-11-01 15:46:10 UTC; 1 day 10h ago
 Main PID: 14513 (bundle)
   CGroup: /user.slice/user-1000.slice/user@1000.service/puma_example.service
           └─14513 puma 4.2.1 (tcp://0.0.0.0:3000) [20191101154450]
```

### puma:log

Uses `journalctl` (part of systemd) to view the log output of the puma service. This task is intended for use as a [run](../commands/run.md) task and accepts command-line arguments. The arguments are passed through to the `journalctl` command. For example:

```
$ tomo run -- puma:log -f
```

Will run this remote script:

```
journalctl -q --user-unit=puma.service -f
```

### puma:tail_log

A convenience method for tailing the puma logs. Equivalent to `tomo run -- puma:log -f`

[socket-activation]: https://github.com/puma/puma/blob/HEAD/docs/systemd.md#socket-activation
