# Tomo::TaskLibrary

This is the primary public API for extending tomo.

A TaskLibrary defines tasks. Every public instance method of a TaskLibrary becomes accessible to tomo as a task of the same name, prefixed by the name of its plugin. For example, this is how the `git:clone` task is defined:

```ruby
module Tomo::Plugin::Git
  class Tasks < Tomo::TaskLibrary
    # This becomes the implementation of the git:clone task
    def clone
      require_setting :git_url
      # ...
    end
  end
end
```

The TaskLibrary base class provides several useful private methods (detailed below) that allow task authors to run commands on the remote host, access tomo settings, and more. For more information on writing tasks, refer to the [Writing Custom Tasks](../tutorials/writing-custom-tasks.md) tutorial.

## Instance methods

### paths → [Tomo::Paths](Paths.md)

Returns a [Paths](Paths.md) object that provides convenient access to settings representing file system paths.

```ruby
paths.current.join("lib") # => "/var/www/my-app/current/lib"
# ...which is syntactic sugar for:
Pathname.new(settings[:current_path]).join("lib")
```

### settings → Hash

Returns a frozen (i.e. read-only) Hash containing all of tomo’s settings. Any [string interpolations](../configuration.md#interpolation) will have already been applied. The keys representing the setting names are always symbols.

```ruby
settings[:application]        # => "my-app"
settings[:deploy_to]          # => "/var/www/my-app"
settings[:non_existing]       # => nil
settings.fetch(:non_existing) # => KeyError
settings[:foo] = "bar"        # => FrozenError
settings.key?(:application)   # => true
settings.key?(:non_existing)  # => false
```

### remote → [Tomo::Remote](Remote.md)

Returns the [Remote](Remote.md) façade that allows scripts to be run on the remote host.

```ruby
remote.run("echo", "hello world")
```

### require_setting(name) → nil

Raises an exception if a setting with the given `name` is not present. In other words, it will raise if `settings[name]` is `nil`. This can be used as a guard clause to ensure that users provide all necessary settings before a task can be run.

```ruby
def clone
  require_setting :git_url
  remote.run "git", "clone", settings[:git_url]
end
```

### require_settings(\*names) → nil

Like `require_setting`, except it accepts an arbitrary number of setting names. Raises if _any_ of the settings are `nil`.

```ruby
require_settings :puma_control_token, :puma_control_url
```

### merge_template(path) → String

Given a local `path` to an [ERB](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html) template, merge that template and return the resulting string. The ERB template can access the same API that tasks and helpers can access, namely: `settings`, `paths`, `remote`, and `raw`.

Here is an example of an ERB template:

```erb
Hello, <%= settings[:application] %>!
```

If `path` begins with a `"."` it is interpreted as a path relative to the tomo configuration file. This allows for easy reference to project-specific templates. For example, given this directory structure:

```plain
.tomo
├── config.rb
└── templates
    └── unicorn.service.erb
```

Then you could reference the template in a setting like this:

```ruby
# .tomo/config.rb

set unicorn_service_template_path: "./templates/unicorn.service.erb"
```

And merge it in a task:

```ruby
merge_template(paths.unicorn_service_template)
```

### dry_run? → true or false

Returns `true` if tomo was started with the `--dry-run` option. This is useful if there are certain code paths you want to ensure are taken during a dry run.

```ruby
def install
  return if remote.bundle?("check", *check_options) && !dry_run?

  remote.bundle("install", *install_options)
end
```

### logger → [Tomo::Logger](Logger.md)

Returns the global [Logger](Logger.md) object that can be used to write messages to tomo’s output.

```ruby
logger.debug "got here"
logger.info "hi!"
logger.warn "uh oh"
```

### die(reason)

Immediately halt task execution by raising an exception. This will automatically print information to stderr about what task failed, on which host, and the `reason` for the failure.

### raw(string) → String

Mark a string as a "raw" value so that it is not automatically escaped. By default tomo applies shell escaping rules for safety. If you explicitly want to invoke shell behavior, use `raw` to prevent these escaping rules.

```ruby
remote.run "ls", "$HOME/.bashrc"
# $ ls $\HOME/.bashrc
# "$HOME/.bashrc": No such file or directory (os error 2)

remote.run "ls", raw("$HOME/.bashrc")
# $ ls $HOME/.bashrc
# /home/deployer/.bashrc
```
