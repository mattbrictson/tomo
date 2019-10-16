# core

The core plugin provides tasks, settings, and helpers that are the fundamental building blocks for most tomo deployments. This plugin is always loaded and available, even if it is not explicitly declared in the configuration file.

## Settings

| Name                           | Purpose                                                                                                                                                                                                   | Default                                |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `application`                  | The name of the application being deployed                                                                                                                                                                | `"default"`                            |
| `concurrency`                  | The maximum number of threads to use when deploying to multiple hosts at once                                                                                                                             | `10`                                   |
| `current_path`                 | Location of the symlink that points to the currently deployed release                                                                                                                                     | `"%{deploy_to}/current"`               |
| `deploy_to`                    | The root directory under which all tomo data, releases, etc. are stored                                                                                                                                   | `"/var/www/%{application}"`            |
| `keep_releases`                | Number of releases to keep when pruning old releases with the [core:clean_releases](#coreclean_releases) task                                                                                             | `10`                                   |
| `linked_dirs`                  | Array of directory names that will be symlinked from the shared directory into each release by the [core:symlink_shared](#coresymlink_shared) task                                                        | `[]`                                   |
| `linked_files`                 | Array of file names that will be symlinked from the shared directory into each release by the [core:symlink_shared](#coresymlink_shared) task                                                             | `[]`                                   |
| `local_user`                   | User name that will be written to the revision log and the release JSON file as the "deploy user".                                                                                                        | `$USER`, `$USERNAME`, or `whoami`      |
| `releases_path`                | Directory where the [deploy](../commands/deploy.md) command creates releases                                                                                                                              | `"%{deploy_to}/releases"`              |
| `release_json_path`            | Path where the [core:write_release_json](#corewrite_release_json) task will write a JSON file describing the release                                                                                      | `"%{release_path}/.tomo_release.json"` |
| `revision_log_path`            | Path where the [core:log_revision](#corelog_revision) task will append a log message with the date and time of the release                                                                                | `"%{deploy_to}/revisions.log"`         |
| `run_args`                     | A special read-only setting where tomo places any extra arguments that are passed to the [run](../commands/run.md) command                                                                                | `[]`                                   |
| `shared_path`                  | Directory where files shared between releases are stored; used by [core:symlink_shared](#coresymlink_shared)                                                                                              | `"%{deploy_to}/shared"`                |
| `ssh_connect_timeout`          | The number of seconds tomo will wait before it gives up when trying to open an SSH connection                                                                                                             | `5`                                    |
| `ssh_executable`               | The name (or full path) of the ssh executable                                                                                                                                                             | `"ssh"`                                |
| `ssh_extra_opts`               | An array of extra command line arguments that tomo will pass to every invocation of the ssh executable                                                                                                    | `["-o", "PasswordAuthentication=no"]`  |
| `ssh_forward_agent`            | Whether to forward authentication when connecting via SSH; needed for seamless git+ssh                                                                                                                    | `true`                                 |
| `ssh_reuse_connections`        | Whether to use `ControlMaster` to keep connections open across multiple invocations of ssh; setting this to `false` will slow down tomo significantly                                                     | `true`                                 |
| `ssh_strict_host_key_checking` | Use `"accept-new"` for a good compromise of security and convenience, `true` for most security, `false` for most convenience; note that older versions of ssh do not understand the `"accept-new"` option | `"accept-new"`                         |
| `tmp_path`                     | Directory where the [setup](../commands/setup.md) command stages temporary files                                                                                                                          | `"/tmp/tomo"`                          |
| `tomo_config_file_path`        | A special read-only setting containing the path to the `config.rb` file that was used to configure tomo                                                                                                   | `"/path/to/.tomo/config.rb"`           |

## Tasks

### core:setup_directories

Creates the `:deploy_to`, `:shared_path`, and `:releases_path` directories so that other tasks that rely on these directories can work. This is one of the first tasks that should be run as part of [setup](../commands/setup.md).

### core:symlink_shared

Creates a symlink for each directory listed in the `:linked_dirs` setting and each file in `:linked_files`. The symlink will point to the directory or file of the same name inside the shared directory. This allows these directories and files to be shared across all releases. Note that if a directory or file already exists in the release, that directory or file will be deleted or overwritten prior to creating the link.

For example, given this configuration:

```ruby
set linked_dirs: ["public/assets"]
set linked_files: ["config/database.yml"]
```

Calling this task will run:

```
mkdir -p /var/www/my-app/shared/public/assets \
         /var/www/my-app/releases/20190604204415/public
cd /var/www/my-app/releases/20190604204415 && rm -rf public/assets
ln -sf /var/www/my-app/shared/public/assets \
       /var/www/my-app/releases/20190604204415/public/assets
ln -sfn /var/www/my-app/shared/config/database.yml \
        /var/www/my-app/releases/20190604204415/config/database.yml
```

`core:symlink_shared` is intended for use as a [deploy](../commands/deploy.md) task. If `:linked_dirs` and `:linked_files` are both empty, running this task has no effect.

### core:symlink_current

Promotes the release that is currently being deployed to become the "current" release by updating the current symlink. `core:symlink_shared` is intended for use as a [deploy](../commands/deploy.md) task. It is typically run after all build steps have completed ([bundler:install](bundler.md#bundlerinstall), [rails:db_migrate](rails.md#railsdb_migrate), [rails:assets_precompile](rails.md#railsassets_precompile), etc.).

### core:clean_releases

Deletes old releases while maintaining the most recent releases and keeping the current release. The total number of releases kept will be based on the `:keep_releases` setting. If this setting is absent or zero, running this task has no effect. If you are continuously deploying your application in an automated fashion, the releases can quickly fill up disk space if they are not pruned; hence the need for this task.

`core:clean_releases` is intended for use as a [deploy](../commands/deploy.md) task. It is typically run at the end of a deployment once everything else has succeeded.

### core:write_release_json

Writes a JSON file to the location specified by the `:release_json_path` setting. This file will contain a JSON object with properties that describe the release. Here is an example:

```json
{
  "branch": "master",
  "author": "matt@example.com",
  "revision": "0d1cb3212e2f9c43aa49fb172d8d9c726163cecf",
  "revision_date": "2019-06-01 17:23:48 -0700",
  "deploy_date": "2019-06-05 19:00:26 -0700",
  "deploy_user": "mbrictson"
}
```

### core:log_revision

Appends a message to a log file specified by the `:revision_log_path` setting. The message contains information about the release. Here is an example entry:

```
2019-06-05 19:00:26 -0700 - 0d1cb3212e2f9c43aa49fb172d8d9c726163cecf (master) deployed by mbrictson
```

## Helpers

All of these methods are available on instances of [Remote](../api/Remote.md) and accept the same `options` as [Remote#run](../api/Remote.md#run42command-4242options-tomoresult).

### remote.capture(\*command, \*\*options) → String

Run the given command, returning the stdout of that command. If the command did not write to stdout, then return an empty String. Note that stderr is ignored, and an exception will be thrown if the command fails.

```ruby
remote.capture("echo", "hello") # => "hello\n"
```

### remote.run?(\*command, \*\*options) → true or false

Run the given command, returning `true` if the command succeeded (exit status of 0) or `false` otherwise.

```ruby
# If java is not installed in the $PATH
remote.run?("which", "java") # => false
```

### remote.write(text:/template:, to:, append: false, \*\*options) → [Tomo::Result](../api/Result.md)

Write the given `text` (a String) or the text resulting from merging the given `template` (a local path to an ERB template file) to the remote path specified by `to:`. Refer to the [merge_template](../api/TaskLibrary.md#merge_templatepath-string) documentation for details on tomo’s ERB templating behavior.

If `append` is `false` (the default), the remote file will completely replaced; if `true`, the file will be appended to. This is designed for small amounts of text (e.g. configuration files), not large or binary data.

```ruby
remote.write text: "hello world!\n",
             to: paths.shared.join("greetings.txt"),
             append: true
```

```ruby
remote.write template: File.expand_path("unicorn.service.erb", __dir__),
             to: ".config/systemd/user/unicorn.service"
```

### remote.ln_sf(target, link, \*\*options) → [Tomo::Result](../api/Result.md)

Create a symlink on the remote host at the path specified at `link` that points to `target`. Deletes any existing file that already exists at the `link` path prior to creating the symlink.

```ruby
remote.ln_sf(paths.shared.join(".env"), paths.release.join(".env"))
# $ ln -sf /var/www/my-app/shared/.env /var/www/my-app/releases/20190604204415/.env
```

### remote.ln_sfn(target, link, \*\*options) → [Tomo::Result](../api/Result.md)

Like `ln_sf` but also passes the `-n` flag, which allows an existing `link` to be deleted even if it is a symlink to a directory.

### remote.mkdir_p(\*directories, \*\*options) → [Tomo::Result](../api/Result.md)

Creates one or more directories on the remote host.

```ruby
remote.mkdir_p(paths.current.dirname, paths.shared)
# $ mkdir -p /var/www/my-app /var/www/my-app/shared
```

### remote.rm_rf(\*paths, \*\*options) → [Tomo::Result](../api/Result.md)

Deletes one or more files or directories on the remote host.

```ruby
remote.rm_rf(paths.tmp)
# $ rm -rf /tmp/tomo
```

### remote.list_files(directory=nil, \*\*options) → [String]

Lists non-hidden files in the specified directory. If `directory` is omitted, the default SSH login directory is used (typically the deploy user’s home directory). The result will be an array of the directory contents.

```ruby
remote.list_files("/var/www/my-app") # => ["current", "releases", "revision.log", shared"]
```

### remote.command_available?(command_name, \*\*options) → true or false

Runs `which` on the remote host to determine whether the given `command_name` is an available executable. Returns `true` if an executable exists, `false` otherwise.

```ruby
remote.command_available?("java") # => false
```

### remote.file?(file, \*\*options) → true or false

Uses the shell expression `[ -f ]` to test whether the given `file` exists on the remote host. Returns `true` if the path exists and is a normal file, `false` otherwise.

```ruby
remote.file?(".bashrc") # => true
```

### remote.executable?(file, \*\*options) → true or false

Uses the shell expression `[ -x ]` to test whether the given `file` exists on the remote host. Returns `true` if the path exists and is executable, `false` otherwise.

```ruby
remote.executable?("/usr/bin/git") # => true
```

### remote.directory?(directory, \*\*options) → true or false

Uses the shell expression `[ -d ]` to test whether the given `directory` exists on the remote host. Returns `true` if the path exists and is a directory, `false` otherwise.

```ruby
remote.directory?("/opt") # => true
```
