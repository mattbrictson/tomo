# Tomo::Remote

A Remote represents an SSH connection to a remote host and provides a façade for building and running shell scripts on that host. A Remote instance is always implicitly available within the context of a task implementation as `remote`. The tomo framework takes care of initializing the SSH connection and setting this reference.

The most basic use of Remote is the [run][] method, which executes a script on the remote host:

```ruby
remote.run "echo", "hello world"
```

For building more complex scripts, Remote offers a variety of builder methods: [chdir](#chdirdir-block-obj), [env](#envhash-block-obj), [prepend](#prepend42command-block-obj), and [umask](#umaskmask-block-obj). Here is an example of some of them:

```ruby
remote.chdir(paths.current) do
  remote.prepend("bundle exec") do
    remote.env(DISABLE_SPRING: "1") do
      remote.run("rails", "db:prepare")
    end
  end
end
# $ cd /var/www/my-app/current && export DISABLE_SPRING=1 && bundle exec rails db:prepare
```

## Instance methods

In addition the methods listed here, all [helpers provided by the core plugin](../plugins/core.md#helpers) are also available, as are helpers from any other plugins that have been explicitly loaded in `.tomo/config.rb`. Refer to the documentation for each plugin for details.

### run(\*command, \*\*options) → [Tomo::Result](Result.md)

Runs a shell script on the remote host via SSH.

The `command` can take one of two forms. If given as a single string, the `command` is executed as a shell script directly; no escaping is performed. This is useful if your script needs to specify output redirection (`>` or `>>`), pipes, or other shell logic (`&&` or `||`). For example:

```ruby
remote.run "bundle exec rails db:prepare > /dev/null && echo 'All set!'"
# $ bundle exec rails db:prepare > /dev/null && echo 'All set!'
```

If the `command` is given as multiple string arguments, then each argument is individually shell-escaped and then assembled into a shell script. This is the preferred way to safely run scripts, especially if the script relies on settings or other user input. For example:

```ruby
settings[:greeting] # => "<this> is safe & easy"
remote.run "echo", settings[:greeting]
# $ echo \<this\>\ is\ safe\ \&\ easy
```

When a script is run it is first echoed to the console and all of its output (stdout and stderr) is streamed to the console as well. If the script fails then an exception will be raised. If the script succeeds, a [Result](Result.md) object will be returned.

This behavior can be customized by specifying `options`, which can include:

| Name              | Purpose                                                                                                                                                                                                                                                                                                                                                              | Default |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `:echo`           | Similar to `-x` in bash, setting `echo: true` will cause the script to be printed to the logger before it is run. If `false`, the script will be run without being printed. If a string is provided, the string will be printed _instead_ of the actual script. This can be useful for redacting or abbreviating sensitive or very long scripts.                     | `true`  |
| `:silent`         | Normally stdout and stderr of the remote script are printed to the logger. Setting `silent: true` will silence this output. Note that even if silenced, the output can still be accessed via the [Result](Result.md).                                                                                                                                                | `false` |
| `:raise_on_error` | By default, if the remote script fails (i.e. returns an exit status other than 0), tomo will raise an exception, stopping execution. If the script being executed is expected to fail, or you would like to take action based on failure, set `raise_on_error: false`. In this case a failed script will return a [Result](Result.md) with `failure?` set to `true`. | `true`  |
| `:default_chdir`  | The working directory where the script will be run by default, if [chdir](#chdirdir-block-obj) is not used. If not specified, the working directory is based on the SSH server's default login directory (almost always this is the user's home directory).                                                                                                          | `nil`   |
| `:attach`         | Setting `attach: true` will cause the script to be run as if [attach][] had been called instead.                                                                                                                                                                                                                                                                     | `false` |
| `:pty`            | Setting `pty: true` will instruct the SSH client to allocate a pseudo-tty when running the script.                                                                                                                                                                                                                                                                   | `false` |

### attach(\*command, \*\*options)

Runs a script on the remote host via SSH, just like [run][], except the Ruby process will be replaced with the SSH process and control completely handed over to SSH (this is done via `Process.exec`). In other words, tomo will immediately stop and it will be like you had run SSH directly.

This is useful for things like running a Rails console, where you would like to "attach" stdin/stdout to the remote process. Typically `pty: true` is used in these situations to force a tty.

```ruby
remote.attach "bundle exec rails console", pty: true
```

`attach` accepts the same options as [run][] (except for `:attach`, which is redundant).

### chdir(dir, &block) → obj

Changes into the specified `dir` when executing a script via [run][] or [attach][]. Must be used with a block. This causes `cd <dir> &&` to be prepended to the script.

```ruby
remote.chdir "/opt/data" do
  remote.run "ls -al"
end
# $ cd /opt/data && ls -al
```

`chdir` returns the value of its block.

### env(hash, &block) → obj

Sets environment variables when executing a script via [run][] or [attach][]. Must be used with a block. This causes `export VAR1=value VAR2=value ... &&` to be prepended to the script. The environment variables are specified as a Ruby hash.

```ruby
remote.env(CLICOLOR_FORCE: "1", RAILS_ENV: "production") do
  remote.run "bundle exec sidekiq"
end
# $ export CLICOLOR_FORCE=1 RAILS_ENV=production && bundle exec sidekiq
```

`env` returns the value of its block.

### prepend(\*command, &block) → obj

Prepends an arbitrary `command` when executing a script via [run][] or [attach][]. Must be used with a block.

```ruby
remote.prepend "bundle", "exec" do
  remote.run "rails routes"
end
# $ bundle exec rails routes
```

`prepend` returns the value of its block.

### umask(mask, &block) → obj

Sets a umask when executing a script via [run][] or [attach][]. Must be used with a block. This causes `umask ... &&` to be prepended to the script. The `mask` can be an Integer (typically expressed in octal) or a String.

```ruby
remote.umask 0o077 do
  remote.run "touch a_file"
end
# $ umask 0077 && touch a_file
```

`umask` returns the value of its block.

### host → [Tomo::Host](Host.md)

The remote SSH host that scripts will be run on.

### release → Hash

A mutable Hash that can be used to share data about the release that is being deployed. Data stored in this Hash can be read by other tasks. In practice this is used by the [git:create_release](../plugins/git.md#gitcreate_release) task to store the branch, author, SHA, date, etc. of the release. This data can then be accessed by other tasks that are interested in this information.

```ruby
result = remote.run('git log -n1 --pretty=format:"%ae"')
remote.release[:author] = result.stdout.chomp
# remote.release[:author] can now be read by other tasks that connect to this host
```

[attach]: #attach42command-4242options
[run]: #run42command-4242options-tomoresult
