# Comparisons

Tomo is a SSH-based deployment tool written in Ruby, and so it is natural to compare it with the many other popular Ruby tools in that category. Here are some specific design choices that make tomo different.

- **Proven built-in Rails support.** Tomo includes all the setup and deployment tasks you need to deploy a basic Rails app. On top of that, every release of tomo is automatically tested to verify that it can successfully deploy the latest versions of Rails, Bundler, and Ruby out of the box.
- **Opinionated defaults.** The tasks built-into tomo provide a very opinionated deployment: rbenv and nodenv to install ruby and node, puma via systemd with socket activation for zero-downtime restarts, 12-factor style configuration (environment variables as opposed to configuration files), and so on. Tomo provides a strong set of production-tested conventions without you needing to piece together snippets from blog posts or tutorials.
- **Easy to extend.** Unlike other Ruby deployment tools that layer DSL monkey patches on top of rake, tomo is built from the ground up with modern CLI conventions, testability, and simplicity in mind. Tomo takes care of SSH connection management for you, and the ordering of deployment and setup operations is purely configuration based. There are no complex chains of prerequisites or programmatic before/after hooks to deal with. All you have to do is write plain Ruby methods utilizing a concise API.

## Code example

To get an idea of how much simpler tomo can be, here is an example of the same task implemented in capistrano vs tomo:

```ruby
# capistrano
task :precompile do
  on release_roles(fetch(:assets_roles)) do
    within release_path do
      with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
        execute :rake, "assets:precompile"
      end
    end
  end
end
```

```ruby
# tomo
def assets_precompile
  remote.rake("assets:precompile")
end
```

## Features

Here's how tomo compares with the most popular Ruby-based deployment tools: Capistrano and Mina.

|                                                                         | Tomo                         | Capistrano                                                    | Mina                           |
| ----------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------- | ------------------------------ |
| First release                                                           | 2019                         | 2009                                                          | 2012                           |
| Required gem dependencies                                               | 0                            | 7                                                             | 2                              |
| Minimum supported ruby version                                          | 3.2                          | 2.0                                                           | 2.0                            |
| Configuration files                                                     | 1 (.tomo/config.rb)          | 3+ (Capfile, config/deploy.rb, config/deploy/\*.rb per stage) | 1 (config/deploy.rb)           |
| Deploy in parallel to multiple hosts                                    | ✅ Yes                       | ✅ Yes                                                        | ❌ No                          |
| Configure multiple environments/stages                                  | ✅ Yes                       | ✅ Yes                                                        | ✅ Yes, via custom rake tasks  |
| Simulate a deploy (dry run)                                             | ✅ Yes                       | ✅ Yes                                                        | ✅ Yes                         |
| Customizable deploy command                                             | ✅ Yes, via config           | ✅ Yes, via rake tasks that attach before/after hooks         | ✅ Yes, via rake task          |
| Built-in setup or “cold deploy” command                                 | ✅ Yes                       | ❌ No                                                         | ✅ Yes                         |
| Automated host setup (ruby, bundler, yarn, etc.)                        | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
| Rollback command                                                        | ❌ No                        | ✅ Yes                                                        | ✅ Yes                         |
| Manage host environment variables (SECRET_KEY_BASE, DATABASE_URL, etc.) | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
| Automated testing of deploying Rails end-to-end                         | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
| Built-in Rails web server tasks                                         | ✅ Yes, puma with systemd    | ❌ No                                                         | ❌ No                          |
| Built-in ruby version manager tasks                                     | ✅ Yes, rbenv                | ❌ No                                                         | ✅ Yes, chruby, rbenv, rvm, ry |
| Built-in node version manager tasks                                     | ✅ Yes, nodenv               | ❌ No                                                         | ❌ No                          |
| SSH command execution                                                   | One at a time                | One at a time                                                 | Batched                        |
| SSH implementation                                                      | Native                       | Ruby (net-ssh)                                                | Native                         |
| SSH connection management                                               | Automatic                    | Explicit                                                      | Automatic                      |
| Task framework                                                          | Tomo-specific                | Rake                                                          | Rake                           |
| Tasks can invoke other tasks                                            | ❌ No                        | ✅ Yes                                                        | ✅ Yes                         |
| Tasks can modify settings on the fly                                    | ❌ No                        | ✅ Yes                                                        | ✅ Yes                         |
| Tasks can have before/after hooks                                       | ❌ No                        | ✅ Yes, via DSL                                               | ✅ Yes, via rake               |
| DSL availability                                                        | Inside task definitions only | Global mixin (monkey patch)                                   | Global mixin (monkey patch)    |
| DSL for running scripts locally (as opposed to on remote host)          | ❌ No                        | ✅ Yes                                                        | ✅ Yes                         |
| DSL for uploading ERB templates                                         | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
