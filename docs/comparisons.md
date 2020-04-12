# Comparisons

Tomo is a SSH-based deployment tool written in Ruby, and so it is natural to compare it with the many other popular Ruby tools in that category. Here are some specific design choices make tomo different.

- **Batteries included.** Running `tomo init` gives you everything you need to deploy a basic Rails app. Literally just specify the `host` in the generated configuration file and go! Tomo itself is constantly tested (via CircleCI) with an automated `tomo init` → `tomo setup` → `tomo deploy` of a real Rails app to verify that this out-of-the-box experience always works with the latest version of Rails.
- **Opinionated defaults.** The tasks built-into tomo provide a very opinionated deployment: rbenv and nodenv to install ruby and node, puma via systemd with socket activation for zero-downtime restarts, 12-factor style configuration (environment variables as opposed to configuration files), and so on. Tomo provides a strong set of production-tested conventions without you needing to piece together snippets from blog posts or tutorials.
- **No Rake.** Many Ruby deployment tools (Capistrano and Mina being the most popular examples) are built on top of Rake, a general purpose tool for making extensible task-based CLIs. Tomo, by contrast, does not use Rake and is a CLI designed specifically for one purpose: deploying Rails via SSH. This means tomo is much more limited than other tools, but conceptually simpler. No need to learn how Rake prerequisites work, the subtle differences between `task do ... end` and `def ... end`, or the esoteric trivia needed to replace or re-invoke a Rake task. Tomo tasks are just plain Ruby methods.
- **Intentionally simple DSL.** Tomo purposely provides a very limited DSL for writing tasks: settings are immutable, so tasks cannot modify them; tasks cannot call other tasks; tasks cannot control the SSH connection. This simplicity makes tasks easy to write and easy to reason about. They have no side effects and can be easily unit tested.

## At a glance

Here's how tomo compares with the most popular Ruby-based deployment tools: Capistrano and Mina.

|                                                                         | Tomo                         | Capistrano                                                    | Mina                           |
| ----------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------- | ------------------------------ |
| First release                                                           | 2019                         | 2009                                                          | 2012                           |
| Required gem dependencies                                               | 0                            | 7                                                             | 2                              |
| Minimum supported ruby version                                          | 2.5                          | 2.0                                                           | 2.0                            |
| Configuration files                                                     | 1 (.tomo/config.rb)          | 3+ (Capfile, config/deploy.rb, config/deploy/\*.rb per stage) | 1 (config/deploy.rb)           |
| Deploy in parallel to multiple hosts                                    | ✅ Yes                       | ✅ Yes                                                        | ❌ No                          |
| Configure multiple environments/stages                                  | ✅ Yes                       | ✅ Yes                                                        | ✅ Yes, via custom rake tasks  |
| Simulate a deploy (dry run)                                             | ✅ Yes                       | ✅ Yes                                                        | ✅ Yes                         |
| Customizable deploy command                                             | ✅ Yes, via config           | ✅ Yes, via rake tasks that attach before/after hooks         | ✅ Yes, via rake task          |
| Built-in setup or “cold deploy” command                                 | ✅ Yes                       | ❌ No                                                         | ✅ Yes                         |
| Automated host setup (ruby, bundler, yarn, etc.)                        | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
| Rollback command                                                        | ❌ No                        | ✅ Yes                                                        | ✅ Yes                         |
| Manage host environment variables (SECRET_KEY_BASE, DATABASE_URL, etc.) | ✅ Yes                       | ❌ No                                                         | ❌ No                          |
| Automated testing of deploying Rails end-to-end                         | ✅ Yes, via CircleCI         | ❌ No                                                         | ❌ No                          |
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
