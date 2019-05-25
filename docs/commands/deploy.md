# deploy

Deploy the current project to remote host(s).

## Usage

```plain
$ tomo deploy [--dry-run] [options]
```

Sequentially run the [deploy](../configuration.md#deployblock) list of tasks specified in `.tomo/config.rb` to deploy the project to a remote host. In practice, a deploy will usually consist of the following steps:

1. Create a release (using the [git:create_release](../plugins/git.md#gitcreate_release) task)
2. Build the project (e.g. [bundler:install](../plugins/bundler.md#bundlerinstall), [rails:assets_precompile](../plugins/rails.md#railsassets_precompile))
3. Migrate data to the meet the requirements of the new release (e.g. [rails:db_migrate](../plugins/rails.md#railsdb_migrate))
4. Make the new release the "current" one ([core:symlink_current](../plugins/core.md#coresymlink_current))
5. Restart the app to use the new current release (e.g. [puma:restart](../plugins/puma.md#pumarestart))
6. Perform any cleanup (e.g. [bundler:clean](../plugins/bundler.md#bundlerclean))

During a deploy, tomo will initialize the `:release_path` setting based on the current date and time (e.g. `/var/www/my-app/releases/20190616214752`). Any tasks that copy files into a release ([git:create_release](../plugins/git.md#gitcreate_release)), or run inside the release ([bundler:install](../plugins/bundler.md#bundlerinstall), [rails:assets_precompile](../plugins/rails.md#railsassets_precompile), [rails:db_migrate](../plugins/rails.md#railsdb_migrate), etc.) will operate using this path. As a result, every `tomo deploy` will create a new entry in the releases directory, and the `current` symlink will point to the release that is currently active, i.e. the most recent successful deploy.

The directory structure on the remote host looks like this:

```plain
/var/www/my-app
├── git_repo/
├── releases/
|   ├── 20190614192115/
|   ├── 20190615034736/
|   └── 20190616214752/
├── shared/
|   ├── bundle/
|   ├── log/
|   ├── node_modules/
|   └── public/
|       └── assets/
├── current -> /var/www/my-app/releases/20190616214752
└── revisions.log
```

This structure is customizable; see the [core plugin settings](../plugins/core.md#settings) for details.

## Options

| Option | Purpose |
| ------ | ------- |
{!deploy_options.md.include!}
{!project_options.md.include!}
{!common_options.md.include!}

## Example

Given the following configuration:

```ruby
host "deployer@localhost", port: 32809

deploy do
  run "env:update"
  run "git:create_release"
  run "core:symlink_shared"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:db_migrate"
  run "rails:db_seed"
  run "rails:assets_precompile"
  run "core:symlink_current"
  run "puma:restart"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
```

Then a deploy would produce:

```plain
$ tomo deploy
tomo deploy v0.1.0
→ Connecting to deployer@localhost:32809
• env:update
• git:create_release
Writing 60 bytes to /var/www/rails-new/git_repo/info/attributes
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git remote update --prune
Fetching origin
cd /var/www/rails-new/git_repo && mkdir -p /var/www/rails-new/releases/20190616214752
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git archive master | tar -x -f - -C /var/www/rails-new/releases/20190616214752
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git log -n1 --date=iso --pretty=format:"%H/%cd/%ae" master
• core:symlink_shared
mkdir -p /var/www/rails-new/shared/.bundle /var/www/rails-new/shared/log /var/www/rails-new/shared/node_modules /var/www/rails-new/shared/public/assets /var/www/rails-new/releases/20190616214752/public
cd /var/www/rails-new/releases/20190616214752 && rm -rf .bundle log node_modules public/assets
ln -sf /var/www/rails-new/shared/.bundle /var/www/rails-new/releases/20190616214752/.bundle
ln -sf /var/www/rails-new/shared/log /var/www/rails-new/releases/20190616214752/log
ln -sf /var/www/rails-new/shared/node_modules /var/www/rails-new/releases/20190616214752/node_modules
ln -sf /var/www/rails-new/shared/public/assets /var/www/rails-new/releases/20190616214752/public/assets
• core:write_release_json
Writing 243 bytes to /var/www/rails-new/releases/20190616214752/.tomo_release.json
• bundler:install
cd /var/www/rails-new/releases/20190616214752 && bundle check --path /var/www/rails-new/shared/bundle
The Gemfile's dependencies are satisfied
• rails:db_migrate
cd /var/www/rails-new/releases/20190616214752 && bundle exec rails db:migrate
• rails:db_seed
cd /var/www/rails-new/releases/20190616214752 && bundle exec rails db:seed
• rails:assets_precompile
cd /var/www/rails-new/releases/20190616214752 && bundle exec rails assets:precompile
yarn install v1.16.0
[1/4] Resolving packages...
[2/4] Fetching packages...
info fsevents@1.2.9: The platform "linux" is incompatible with this module.
info "fsevents@1.2.9" is an optional dependency and failed compatibility check. Excluding it from installation.
[3/4] Linking dependencies...
warning " > webpack-dev-server@3.3.1" has unmet peer dependency "webpack@^4.0.0".
warning "webpack-dev-server > webpack-dev-middleware@3.7.0" has unmet peer dependency "webpack@^4.0.0".
[4/4] Building fresh packages...
Done in 27.71s.
I, [2019-06-16T21:48:36.682912 #36032]  INFO -- : Writing /var/www/rails-new/releases/20190616214752/public/assets/application-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.css
I, [2019-06-16T21:48:36.683798 #36032]  INFO -- : Writing /var/www/rails-new/releases/20190616214752/public/assets/application-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.css.gz
Compiling…
Compiled all packs in /var/www/rails-new/releases/20190616214752/public/packs
• core:symlink_current
ln -sf /var/www/rails-new/releases/20190616214752 /var/www/rails-new/current-9f36bc6f645ade90
mv -fT /var/www/rails-new/current-9f36bc6f645ade90 /var/www/rails-new/current
• puma:restart
cd /var/www/rails-new/current && bundle exec pumactl --control-url tcp://127.0.0.1:9293 --control-token tomo restart
Puma is not running. Starting it now.
cd /var/www/rails-new/current && bundle exec puma --daemon --control-url tcp://127.0.0.1:9293 --control-token tomo
Puma starting in single mode...
* Version 3.12.1 (ruby 2.6.3-p62), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: production
* Daemonizing...
• core:clean_releases
readlink /var/www/rails-new/current
cd /var/www/rails-new/releases && ls -A1
• bundler:clean
cd /var/www/rails-new/releases/20190616214752 && bundle clean
• core:log_revision
Writing 100 bytes to /var/www/rails-new/revisions.log
```
