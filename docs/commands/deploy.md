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
  run "puma:check_active"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
```

Then a deploy would produce:

```plain
$ tomo deploy
tomo deploy v0.9.0
→ Connecting to deployer@localhost:32829
• env:update
• git:create_release
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git remote update --prune
Fetching origin
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git log -n1 --date=iso --pretty=format:"%H/%cd/%ae" master --
Writing 60 bytes to /var/www/rails-new/git_repo/info/attributes
mkdir -p /var/www/rails-new/releases/20191019200551
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git archive master | tar -x -f - -C /var/www/rails-new/releases/20191019200551
• core:symlink_shared
mkdir -p /var/www/rails-new/shared/log /var/www/rails-new/shared/node_modules /var/www/rails-new/shared/public/assets /var/www/rails-new/shared/tmp/cache /var/www/rails-new/shared/tmp/pids /var/www/rails-new/shared/tmp/sockets /var/www/rails-new/releases/20191019200551/public /var/www/rails-new/releases/20191019200551/tmp
cd /var/www/rails-new/releases/20191019200551 && rm -rf log node_modules public/assets tmp/cache tmp/pids tmp/sockets
ln -sf /var/www/rails-new/shared/log /var/www/rails-new/releases/20191019200551/log
ln -sf /var/www/rails-new/shared/node_modules /var/www/rails-new/releases/20191019200551/node_modules
ln -sf /var/www/rails-new/shared/public/assets /var/www/rails-new/releases/20191019200551/public/assets
ln -sf /var/www/rails-new/shared/tmp/cache /var/www/rails-new/releases/20191019200551/tmp/cache
ln -sf /var/www/rails-new/shared/tmp/pids /var/www/rails-new/releases/20191019200551/tmp/pids
ln -sf /var/www/rails-new/shared/tmp/sockets /var/www/rails-new/releases/20191019200551/tmp/sockets
• core:write_release_json
Writing 299 bytes to /var/www/rails-new/releases/20191019200551/.tomo_release.json
• bundler:install
cd /var/www/rails-new/releases/20191019200551 && bundle check
The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run `bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java`.
The Gemfile's dependencies are satisfied
• rails:db_migrate
cd /var/www/rails-new/releases/20191019200551 && bundle exec rails db:migrate
• rails:db_seed
cd /var/www/rails-new/releases/20191019200551 && bundle exec rails db:seed
• rails:assets_precompile
cd /var/www/rails-new/releases/20191019200551 && bundle exec rails assets:precompile
yarn install v1.16.0
[1/4] Resolving packages...
[2/4] Fetching packages...
info fsevents@1.2.9: The platform "linux" is incompatible with this module.
info "fsevents@1.2.9" is an optional dependency and failed compatibility check. Excluding it from installation.
[3/4] Linking dependencies...
warning " > webpack-dev-server@3.8.1" has unmet peer dependency "webpack@^4.0.0".
warning "webpack-dev-server > webpack-dev-middleware@3.7.2" has unmet peer dependency "webpack@^4.0.0".
[4/4] Building fresh packages...
Done in 30.68s.
I, [2019-10-19T20:06:30.645395 #33263]  INFO -- : Writing /var/www/rails-new/releases/20191019200551/public/assets/application-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.css
I, [2019-10-19T20:06:30.645832 #33263]  INFO -- : Writing /var/www/rails-new/releases/20191019200551/public/assets/application-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.css.gz
Compiling…
Compiled all packs in /var/www/rails-new/releases/20191019200551/public/packs

WARNING: We noticed you're using the `useBuiltIns` option without declaring a core-js version. Currently, we assume version 2.x when no version is passed. Since this default version will likely change in future versions of Babel, we recommend explicitly setting the core-js version you are using via the `corejs` option.

You should also be sure that the version you pass to the `corejs` option matches the version specified in your `package.json`'s `dependencies` section. If it doesn't, you need to run one of the following commands:

  npm install --save core-js@2    npm install --save core-js@3
  yarn add core-js@2              yarn add core-js@3


• core:symlink_current
ln -sf /var/www/rails-new/releases/20191019200551 /var/www/rails-new/current-0d3d2f7a6648294a
mv -fT /var/www/rails-new/current-0d3d2f7a6648294a /var/www/rails-new/current
• puma:restart
systemctl --user start puma_rails-new.socket
systemctl --user restart puma_rails-new.service
• puma:check_active
Checking if puma is active and listening on port 3000...
systemctl --user is-active puma_rails-new.service
curl -sS --connect-timeout 1 --max-time 10 http://localhost:3000 > /dev/null
systemctl --user status puma_rails-new.service
● puma_rails-new.service
   Loaded: loaded (enabled; vendor preset: enabled)
   Active: active (running)
• core:clean_releases
readlink /var/www/rails-new/current
cd /var/www/rails-new/releases && ls -A1
• bundler:clean
cd /var/www/rails-new/releases/20191019200551 && bundle clean
The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run `bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java`.
• core:log_revision
Writing 100 bytes to /var/www/rails-new/revisions.log
✔ Deployed rails-new to deployer@localhost:32829
```
