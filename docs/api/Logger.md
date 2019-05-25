# Tomo::Logger

Provides a simple interface for logging messages to stdout and stderr. In multi-host deployments, messages are automatically prefixed with `[1]`, `[2]`, etc. based on current host. This makes it easier to distinguish where log messages are coming from.

```
$ tomo run bundler:clean
tomo run v0.1.0
[1] → Connecting to deployer@web1.example.com
[2] → Connecting to deployer@web2.example.com
[1] • bundler:clean
[2] • bundler:clean
[1] cd /home/deployer/apps/my-app/current && bundle clean
[2] cd /home/deployer/apps/my-app/current && bundle clean
✔ Ran bundler:clean on deployer@web1.example.com and deployer@web2.example.com
```

If tomo is run in `--dry-run` mode, log messages are prefixed with a `*` to indicate the commands are being simulated.

```
$ tomo run bundler:clean --dry-run
tomo run v0.1.0
* [1] → Connecting to deployer@web1.example.com
* [2] → Connecting to deployer@web2.example.com
* [1] • bundler:clean
* [2] • bundler:clean
* [1] cd /home/deployer/apps/my-app/current && bundle clean
* [2] cd /home/deployer/apps/my-app/current && bundle clean
* Simulated bundler:clean on deployer@web1.example.com and deployer@web2.example.com (dry run)
```

## Instance methods

### debug(message) → nil

Prints a message to _stderr_ in gray with a `DEBUG:` prefix. Debug messages are only shown if tomo is run with the `--debug` option. Otherwise this is a no-op.

### info(message) → nil

Prints a message to _stdout_.

### warn(message) → nil

Prints a message to _stderr_ with a red `WARNING:` prefix.

### error(message) → nil

Prints a message to _stderr_ with a red `ERROR:` prefix, indented, and with leading and trailing blank lines for extra emphasis.
