# Writing Custom Tasks

In this tutorial we will build a "cron" plugin to demonstrate how to write custom tasks in tomo. Here are the main takeaways:

- Use `.tomo/plugins/*.rb` to define plugins
- A task is any public Ruby method within a plugin
- Tasks can access the [TaskLibrary](../api/TaskLibrary.md#instance-methods) API
- Use [remote.run](../api/Remote.md#run42command-4242options-tomoresult) to execute scripts on the remote host

Here's the final product:

```ruby
# .tomo/config.rb
plugin "./plugins/cron.rb"
```

```ruby
# .tomo/plugins/cron.rb
def show
  remote.run "crontab -l", raise_on_error: false
end

def install
  template_path = File.expand_path("../templates/crontab.erb", __dir__)
  crontab = merge_template(template_path)
  remote.run "echo #{crontab.shellescape} | crontab -",
             echo: "echo [template:.tomo/templates/crontab.erb] | crontab -"
end
```

```sh
# .tomo/templates/crontab.erb
SHELL=/bin/bash
0 6 * * * . $HOME/.bashrc; cd <%= paths.current %>; bundle exec rails runner PeriodicTask.call > <%= paths.shared.join("log/periodic-task.log") %> 2>&1
```

Before we get there, let's review the basics.

## What is a plugin?

Plugins extend tomo by providing some or all of these three things: tasks, helpers, and default settings. Plugins are either built into tomo (e.g. [git](../plugins/git.md), [rails](../plugins/rails.md)), provided by gems (e.g. [tomo-plugin-sidekiq](https://github.com/mattbrictson/tomo-plugin-sidekiq)), or loaded from `./tomo/plugins/*.rb` within a tomo project. This tutorial will focus on project-specific plugins, which are the easiest to write. Once you are ready to share your plugin amongst multiple projects (or with the larger tomo community), check out the [Publishing a Plugin](publishing-a-plugin.md) tutorial to learn how to package a plugin as a gem.

## What is a task?

**In tomo, a task is a plain Ruby method provided by a plugin.** Task methods take zero arguments. Here is a trivial example:

```ruby
# .tomo/plugins/foo.rb

# This defines a foo:hello task
def hello
  logger.info "hello, world!"
end
```

The name of the plugin is set automatically based on the name of the `.rb` file, which in this case is "foo". Any public method defined in `foo.rb` becomes a tomo task. So the example above defines a `foo:hello` task that prints "hello, world!" to the console.

## What can a task do?

Behind the scenes, the Ruby methods you define in your plugin are actually methods on a subclass of [TaskLibrary](../api/TaskLibrary.md). That means you have full access to the TaskLibrary API within your task method, which includes:

- [logger](../api/TaskLibrary.md#logger-tomologger) for printing output (as seen in the example above)
- [remote](../api/TaskLibrary.md#remote-tomoremote) for running scripts on the remote host
- [settings](../api/TaskLibrary.md#settings-hash) for accessing project configuration
- [paths](../api/TaskLibrary.md#paths-tomopaths) for convenient access to filesystem paths on the remote host
- and [more…](../api/TaskLibrary.md#instance-methods)

For example, a simplified, annotated version of the `git:clone` task that is built into tomo looks like this:

```ruby
def clone
  # Halt tomo with an error message if the :git_url setting is nil/unspecified
  require_setting :git_url

  # Run "mkdir -p" on the remote host to create the parent directory
  # of the :git_repo_path setting
  remote.mkdir_p(paths.git_repo.dirname)

  # Run "git clone ..." on the remote host to clone the repo into :git_repo_path
  remote.run("git", "clone", "--mirror", settings[:git_url], paths.git_repo)
end
```

## When are tasks run?

Tomo does not have hooks and tasks cannot invoke other tasks. That means that tasks only run when explicitly requested by the user. There are three ways to run a task:

- [deploy](../commands/deploy.md)
- [setup](../commands/setup.md)
- [run](../commands/run.md)

For deploy and setup, users invoke your task by including it in the [deploy](../configuration.md#deployblock) or [setup](../configuration.md#setupblock) list of tasks in `.tomo/config.rb`. Additionally, any task can be run on-demand from the command line, like this:

```plain
$ tomo run foo:hello
```

In the command line case, users can optionally pass arguments to a task. These arguments become available to the task via the `:run_args` setting. For example, the `rails:console` task supports command line arguments like this:

```ruby
def console
  # If this task is run like `tomo run -- rails:console --sandbox`
  # then settings[:run_args] will be ["--sandbox"]
  args = settings[:run_args]

  remote.chdir(paths.current) do
    remote.run("bundle", "exec", "rails", "console", *args, attach: true)
  end
end
```

## How do tasks connect to remote hosts?

Notice that none of the examples in this tutorial makes any mention of opening/closing connections or specifying hosts or roles. That is because tomo takes care of connecting to remote hosts and automatically decides which tasks should run on which hosts based on project configuration. By the time a task method is invoked, any necessary SSH connection is already established; `remote` implicitly refers to that connection.

In other words, as a tomo task author you only need to be concerned about _what_ remote scripts to run, not _where_ or _how_ they are executed. For a more in-depth explanation of how configuration drives tomo’s behavior, refer to the [configuration docs](../configuration.md).

## Tutorial

Let's build something using this knowledge of how tomo tasks work.

### Objective

Say we have a Rails app that needs to run code – `PeriodicTask.call`, for example – every day at 06:00. We'd like to do this with a cron job and use tomo to install that cron job on the remote host. For troubleshooting purposes it would be nice to view the list of cron jobs with tomo as well. That sounds like two distinct tomo tasks:

1. `cron:install` to install the cron job
2. `cron:show` to list the currently installed cron jobs

We want `cron:install` to be run when we initially set up the remote host. In other words, it should run as part of `tomo setup`. On the other hand, `cron:show` is a utility that we can use on the CLI when needed.

### cron:show

We'll start by building the simpler of the two tasks: `cron:show`. First, let's try to run that task:

```plain
$ tomo run cron:show
tomo run v1.0.0

  ERROR: cron:show is not a recognized task.
  To see a list of all available tasks, run tomo tasks.
```

We haven't written the task yet, so this error makes sense. Let's build a skeleton of the `cron:show` task to fix this error. Create a `.tomo/plugins/cron.rb` task like this:

```ruby
# .tomo/plugins/cron.rb

def show
  logger.info "Hi"
end
```

And don't forget to load the plugin in `.tomo/config.rb`:

```ruby
# .tomo/config.rb

plugin "./plugins/cron.rb"
```

Now we can try again:

```plain
$ tomo run cron:show
tomo run v1.0.0
→ Connecting to deployer@app.example.com
• cron:show
Hi
✔ Ran cron:show on deployer@app.example.com
```

Great! To get a list of cron jobs, we need to run `crontab -l` on the remote host:

```ruby
def show
  remote.run "crontab -l"
end
```

One more try:

```plain
$ tomo run cron:show
tomo run v1.0.0
→ Connecting to deployer@app.example.com
• cron:show
crontab -l
no crontab for deployer

  ERROR: The following script failed on deployer@app.example.com (exit status 1).

    crontab -l

  You can manually re-execute the script via SSH as follows:

    ssh -o LogLevel\=ERROR -A -o ConnectTimeout\=5 -o StrictHostKeyChecking\=accept-new -o ControlMaster\=auto -o ControlPath\=/var/folders/_v/j_5kgc6n1nz5pb7kfkzz3r5c0000gn/T/tomo_ssh_1f061db77f81ae9e -o ControlPersist\=30s -o PasswordAuthentication\=no deployer@app.example.com -- crontab\ -l

  For more troubleshooting info, run tomo again using the --debug option.

  no crontab for deployer
```

Uh oh. There are no cron jobs installed yet, so `crontab -l` exits with an error. By default, tomo assumes that any remote command the exits with an error status is considered fatal. In this case we just want to see the error output from the `crontab` command and continue without complaint; that's where the `raise_on_error: false` option comes into play:

```ruby
def show
  remote.run "crontab -l", raise_on_error: false
end
```

Now we're all good:

```plain
$ tomo run cron:show
tomo run v1.0.0
→ Connecting to deployer@app.example.com
• cron:show
crontab -l
no crontab for deployer
✔ Ran cron:show on deployer@app.example.com
```

### cron:install

Before we said that we want a `cron:install` task that runs as part of `tomo setup`. Let's start by adding that task to the list of setup tasks in `.tomo/config.rb`:

```ruby
# .tomo/config.rb

setup do
  # ... other tasks omitted for brevity
  run "cron:install"
end
```

If we try to run `tomo setup` at this point, we'll get an error as expected:

```plain
$ tomo setup
tomo setup v1.0.0

  ERROR: cron:install is not a recognized task.
  To see a list of all available tasks, run tomo tasks.

  Did you mean rbenv:install?
```

Cron jobs can be installed by piping a list of cron definitions to `crontab -` (the `-` means to read the definitions from stdin). We can take advantage of this to write a simple `cron:install` task:

```ruby
def install
  crontab = <<~CRONTAB
    SHELL=/bin/bash
    0 6 * * * . $HOME/.bashrc; cd /var/www/my-app/current; bundle exec rails runner PeriodicTask.call > /var/www/my-app/shared/log/periodic-task.log 2>&1
  CRONTAB
  remote.run "echo #{crontab.shellescape} | crontab -"
end
```

Note that we are using `shellescape` as part of Ruby's built-in [shellwords](https://ruby-doc.org/stdlib-2.6.3/libdoc/shellwords/rdoc/Shellwords.html) library to safely build the script.

We can see what this task does without actually affecting the remote host by using `--dry-run` option:

```plain
$ tomo run cron:install --dry-run
tomo run v1.0.0
* → Connecting to deployer@app.example.com
* • cron:install
* echo SHELL\=/bin/bash'
* '0\ 6\ \*\ \*\ \*\ .\ \$HOME/.bashrc\;\ cd\ /var/www/my-app/current\;\ bundle\ exec\ rails\ runner\ PeriodicTask.call\ \>\ /var/www/my-app/shared/log/periodic-task.log\ 2\>\&1'
* ' | crontab -
* Simulated cron:install on deployer@app.example.com (dry run)
```

Looks good! But we if we made it more powerful with some ERB templating?

### Templates

Tomo offers a convenient way to use ERB templates with it’s built-in [merge_template](../api/TaskLibrary.md#merge_templatepath-string) and [write](../plugins/core.md#remotewritetexttemplate-to-append-false-4242options-tomoresult) methods. We can use `merge_template` instead of a hard-coding the cron job:

```ruby
def install
  template_path = File.expand_path("../templates/crontab.erb", __dir__)
  crontab = merge_template(template_path)
  remote.run "echo #{crontab.shellescape} | crontab -"
end
```

The ERB template has access to all the same APIs as our task methods; that means we can remove the hard-coded paths from our original cron job specification and use tomo's `paths` helper. So our ERB template file (`.tomo/templates/crontab.erb`) could look like this:

```sh
# .tomo/templates/crontab.erb
SHELL=/bin/bash
0 6 * * * . $HOME/.bashrc; cd <%= paths.current %>; bundle exec rails runner PeriodicTask.call > <%= paths.shared.join("log/periodic-task.log") %> 2>&1
```

Let's check that it still works:

```plain
$ tomo run cron:install --dry-run
tomo run v1.0.0
* → Connecting to deployer@app.example.com
* • cron:install
* echo SHELL\=/bin/bash'
* '0\ 6\ \*\ \*\ \*\ .\ \$HOME/.bashrc\;\ cd\ /var/www/my-app/current\;\ bundle\ exec\ rails\ runner\ PeriodicTask.call\ \>\ /var/www/my-app/shared/log/periodic-task.log\ 2\>\&1'
* ' | crontab -
* Simulated cron:install on deployer@app.example.com (dry run)
```

That's great, but the output is really verbose. Do we really need to see the full contents of the crontab being echoed? What if our template becomes really large? In tomo, you can mute this output using `echo: false`, but you can also provide an echo string to show instead of the command. We can use this to echo an abbreviated version:

```ruby
def install
  template_path = File.expand_path("../templates/crontab.erb", __dir__)
  crontab = merge_template(template_path)
  remote.run "echo #{crontab.shellescape} | crontab -",
             echo: "echo [template:.tomo/templates/crontab.erb] | crontab -"
end
```

And then try it:

```plain
$ tomo run cron:install --dry-run
tomo run v1.0.0
* → Connecting to deployer@app.example.com
* • cron:install
* echo [template:.tomo/templates/crontab.erb] | crontab -
* Simulated cron:install on deployer@app.example.com (dry run)
```

Ah, much cleaner!

### The result

We now have a `cron:install` task that will automatically run as part of `tomo setup`, or can be run manually using `tomo run cron:install`. Let's try it for real:

```plain
$ tomo setup
... [snip] ...
• cron:install
echo [template:.tomo/templates/crontab.erb] | crontab -
✔ Performed setup of my-app on deployer@app.example.com
```

And we can see what is installed with our `cron:show` task:

```plain
$ tomo run cron:show
tomo run v1.0.0
→ Connecting to deployer@app.example.com
• cron:show
crontab -l
SHELL=/bin/bash
0 6 * * * . $HOME/.bashrc; cd /home/deployer/apps/my-app/current; bundle exec rails runner PeriodicTask.call > /home/deployer/apps/my-app/shared/log/periodic-task.log 2>&1

✔ Ran cron:show on deployer@app.example.com
```

## Next steps

This tutorial introduced you to writing custom tasks in tomo, but there is much more to explore. For next steps, check out these APIs:

- [Tomo::TaskLibrary](../api/TaskLibrary.md)
- [Tomo::Remote](../api/Remote.md)
- [Tomo::Result](../api/Result.md)
- [Tomo::Paths](../api/Paths.md)
- [core plugin helpers](../plugins/core.md#helpers) (additional methods mixed into the Remote API)

And for inspiration, look no further than tomo itself, which has several built-in plugins in [lib/tomo/plugin](https://github.com/mattbrictson/tomo/tree/main/lib/tomo/plugin).
