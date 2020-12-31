# setup

Prepare the current project for its first deploy.

## Usage

```plain
$ tomo setup [--dry-run] [options]
```

Prepare the remote host for its first deploy by sequentially running the
[setup](../configuration.md#setupblock) list of tasks specified in `.tomo/config.rb`. These tasks typically create directories, initialize data stores, install prerequisite tools, and perform other one-time actions that are necessary before a deploy can take place.

During setup, tomo will initialize the `:release_path` setting to be a temporary directory based on the current date and time (e.g. `/tmp/tomo-a4DBHX0P/20190616214752`). This means setup tasks (e.g. [rails:db_create](../plugins/rails.md#railsdb_create), [rails:db_schema_load](../plugins/rails.md#railsdb_schema_load)) run in a location that won't be deployed as an actual release.

## Options

| Option | Purpose |
| ------ | ------- |
{!deploy_options.md.include!}
{!project_options.md.include!}
{!common_options.md.include!}

## Example

Given the following configuration:

```ruby
host "deployer@localhost", port: 32829

setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:clone"
  run "git:create_release"
  run "core:symlink_shared"
  run "nodenv:install"
  run "rbenv:install"
  run "bundler:upgrade_bundler"
  run "bundler:config"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_schema_load"
  run "rails:db_seed"
  run "puma:setup_systemd"
end
```

Then a setup would produce:

```plain
$ tomo setup
tomo setup v1.0.0
→ Connecting to deployer@localhost:32829
• env:setup
Writing 314 bytes to /var/www/rails-new/envrc
cat .bashrc
Writing 3845 bytes to .bashrc
• core:setup_directories
mkdir -p /var/www/rails-new /var/www/rails-new/releases /var/www/rails-new/shared
• git:clone
[ -d /var/www/rails-new/git_repo ]
mkdir -p /var/www/rails-new
export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git clone --mirror git@github.com:mattbrictson/rails-new.git /var/www/rails-new/git_repo
Cloning into bare repository '/var/www/rails-new/git_repo'...
Warning: Permanently added 'github.com,192.30.255.113' (RSA) to the list of known hosts.
• git:create_release
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git remote update --prune
Fetching origin
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git log -n1 --date=iso --pretty=format:"%H/%cd/%ae" main --
Writing 60 bytes to /var/www/rails-new/git_repo/info/attributes
mkdir -p /tmp/tomo-a4DBHX0P/20191019200138
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git archive main | tar -x -f - -C /tmp/tomo-a4DBHX0P/20191019200138
• core:symlink_shared
mkdir -p /var/www/rails-new/shared/log /var/www/rails-new/shared/node_modules /var/www/rails-new/shared/public/assets /var/www/rails-new/shared/tmp/cache /var/www/rails-new/shared/tmp/pids /var/www/rails-new/shared/tmp/sockets /tmp/tomo-a4DBHX0P/20191019200138/public /tmp/tomo-a4DBHX0P/20191019200138/tmp
cd /tmp/tomo-a4DBHX0P/20191019200138 && rm -rf log node_modules public/assets tmp/cache tmp/pids tmp/sockets
ln -sf /var/www/rails-new/shared/log /tmp/tomo-a4DBHX0P/20191019200138/log
ln -sf /var/www/rails-new/shared/node_modules /tmp/tomo-a4DBHX0P/20191019200138/node_modules
ln -sf /var/www/rails-new/shared/public/assets /tmp/tomo-a4DBHX0P/20191019200138/public/assets
ln -sf /var/www/rails-new/shared/tmp/cache /tmp/tomo-a4DBHX0P/20191019200138/tmp/cache
ln -sf /var/www/rails-new/shared/tmp/pids /tmp/tomo-a4DBHX0P/20191019200138/tmp/pids
ln -sf /var/www/rails-new/shared/tmp/sockets /tmp/tomo-a4DBHX0P/20191019200138/tmp/sockets
• nodenv:install
export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH && curl -fsSL https://github.com/nodenv/nodenv-installer/raw/master/bin/nodenv-installer | bash
Installing nodenv with git...
Initialized empty Git repository in /home/deployer/.nodenv/.git/
Updating origin
From https://github.com/nodenv/nodenv
 * [new branch]      master     -> origin/master
 * [new tag]         0.2.0      -> 0.2.0
 * [new tag]         v0.1.0     -> v0.1.0
 * [new tag]         v0.2.0     -> v0.2.0
 * [new tag]         v0.3.0     -> v0.3.0
 * [new tag]         v0.4.0     -> v0.4.0
 * [new tag]         v1.0.0     -> v1.0.0
 * [new tag]         v1.1.0     -> v1.1.0
 * [new tag]         v1.1.1     -> v1.1.1
 * [new tag]         v1.1.2     -> v1.1.2
 * [new tag]         v1.2.0     -> v1.2.0
 * [new tag]         v1.3.0     -> v1.3.0
Branch 'master' set up to track remote branch 'master' from 'origin'.
Already on 'master'
make: Entering directory '/home/deployer/.nodenv/src'
gcc -fPIC     -c -o realpath.o realpath.c
gcc -shared -Wl,-soname,../libexec/nodenv-realpath.dylib  -o ../libexec/nodenv-realpath.dylib realpath.o
make: Leaving directory '/home/deployer/.nodenv/src'

Installing node-build with git...
Cloning into '/home/deployer/.nodenv/plugins/node-build'...

Running doctor script to verify installation...
Checking for `nodenv' in PATH: /home/deployer/.nodenv/bin/nodenv
Checking for nodenv shims in PATH: OK
Checking `nodenv install' support: /home/deployer/.nodenv/plugins/node-build/bin/nodenv-install (node-build 4.6.4-9-g3a5ae01b)
Counting installed Node versions: none
  There aren't any Node versions installed under `/home/deployer/.nodenv/versions'.
  You can install Node versions like so: nodenv install 2.2.4
Auditing installed plugins: OK

All done!
Note that this installer doesn't yet configure your shell startup files:
1. You'll want to ensure that `~/.nodenv/bin' is added to PATH.
2. Run `nodenv init' to see instructions how to configure nodenv for your shell.
3. Launch a new terminal window to verify that the configuration is correct.

cat .bashrc
Writing 3944 bytes to .bashrc
nodenv versions
nodenv install 10.16.0
Downloading node-v10.16.0-linux-x64.tar.gz...
-> https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-x64.tar.gz
Installing node-v10.16.0-linux-x64...
Installed node-v10.16.0-linux-x64 to /home/deployer/.nodenv/versions/10.16.0

nodenv global 10.16.0
npm i -g yarn@1.16.0
/home/deployer/.nodenv/versions/10.16.0/bin/yarnpkg -> /home/deployer/.nodenv/versions/10.16.0/lib/node_modules/yarn/bin/yarn.js
/home/deployer/.nodenv/versions/10.16.0/bin/yarn -> /home/deployer/.nodenv/versions/10.16.0/lib/node_modules/yarn/bin/yarn.js
+ yarn@1.16.0
added 1 package in 0.54s
• rbenv:install
export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH && curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
Installing rbenv with git...
Initialized empty Git repository in /home/deployer/.rbenv/.git/
Updating origin
From https://github.com/rbenv/rbenv
 * [new branch]      master     -> origin/master
 * [new tag]         v0.1.0     -> v0.1.0
 * [new tag]         v0.1.1     -> v0.1.1
 * [new tag]         v0.1.2     -> v0.1.2
 * [new tag]         v0.2.0     -> v0.2.0
 * [new tag]         v0.2.1     -> v0.2.1
 * [new tag]         v0.3.0     -> v0.3.0
 * [new tag]         v0.4.0     -> v0.4.0
 * [new tag]         v1.0.0     -> v1.0.0
 * [new tag]         v1.1.0     -> v1.1.0
 * [new tag]         v1.1.1     -> v1.1.1
 * [new tag]         v1.1.2     -> v1.1.2
Already on 'master'
Branch 'master' set up to track remote branch 'master' from 'origin'.
make: Entering directory '/home/deployer/.rbenv/src'
gcc -fPIC     -c -o realpath.o realpath.c
gcc -shared -Wl,-soname,../libexec/rbenv-realpath.dylib  -o ../libexec/rbenv-realpath.dylib realpath.o
make: Leaving directory '/home/deployer/.rbenv/src'

Installing ruby-build with git...
Cloning into '/home/deployer/.rbenv/plugins/ruby-build'...

Running doctor script to verify installation...
Checking for `rbenv' in PATH: /home/deployer/.rbenv/bin/rbenv
Checking for rbenv shims in PATH: OK
Checking `rbenv install' support: /home/deployer/.rbenv/plugins/ruby-build/bin/rbenv-install (ruby-build 20191004)
Counting installed Ruby versions: none
  There aren't any Ruby versions installed under `/home/deployer/.rbenv/versions'.
  You can install Ruby versions like so: rbenv install 2.2.4
Checking RubyGems settings: OK
Auditing installed plugins: OK

All done!
Note that this installer doesn't yet configure your shell startup files:
1. You'll want to ensure that `~/.rbenv/bin' is added to PATH.
2. Run `rbenv init' to see instructions how to configure rbenv for your shell.
3. Launch a new terminal window to verify that the configuration is correct.

cat .bashrc
Writing 4041 bytes to .bashrc
rbenv versions
Installing ruby 2.6.5 -- this may take several minutes
CFLAGS=-O3 rbenv install 2.6.5
Downloading ruby-2.6.5.tar.bz2...
-> https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.bz2
Installing ruby-2.6.5...
Installed ruby-2.6.5 to /home/deployer/.rbenv/versions/2.6.5

rbenv global 2.6.5
• bundler:upgrade_bundler
tail -n 10 /tmp/tomo-a4DBHX0P/20191019200138/Gemfile.lock
gem install bundler --conservative --no-document -v 2.0.2
Successfully installed bundler-2.0.2
1 gem installed
• bundler:config
mkdir -p .bundle
Writing 146 bytes to .bundle/config
• bundler:install
cd /tmp/tomo-a4DBHX0P/20191019200138 && bundle check
The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run `bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java`.
The following gems are missing
 * rake (13.0.0)
 * concurrent-ruby (1.1.5)
 * i18n (1.7.0)
 * minitest (5.12.2)
 * thread_safe (0.3.6)
 * tzinfo (1.2.5)
 * zeitwerk (2.2.0)
 * activesupport (6.0.0)
 * builder (3.2.3)
 * erubi (1.9.0)
 * mini_portile2 (2.4.0)
 * nokogiri (1.10.4)
 * rails-dom-testing (2.0.3)
 * crass (1.0.4)
 * loofah (2.3.0)
 * rails-html-sanitizer (1.3.0)
 * actionview (6.0.0)
 * rack (2.0.7)
 * rack-test (1.1.0)
 * actionpack (6.0.0)
 * nio4r (2.5.2)
 * websocket-extensions (0.1.4)
 * websocket-driver (0.7.1)
 * actioncable (6.0.0)
 * globalid (0.4.2)
 * activejob (6.0.0)
 * activemodel (6.0.0)
 * activerecord (6.0.0)
 * mimemagic (0.3.3)
 * marcel (0.3.3)
 * activestorage (6.0.0)
 * mini_mime (1.0.2)
 * mail (2.7.1)
 * actionmailbox (6.0.0)
 * actionmailer (6.0.0)
 * actiontext (6.0.0)
 * msgpack (1.3.1)
 * bootsnap (1.4.5)
 * ffi (1.11.1)
 * jbuilder (2.9.1)
 * method_source (0.9.2)
 * puma (3.12.1)
 * rack-proxy (0.6.5)
 * thor (0.20.3)
 * railties (6.0.0)
 * sprockets (3.7.2)
 * sprockets-rails (3.2.1)
 * rails (6.0.0)
 * rb-fsevent (0.10.3)
 * rb-inotify (0.10.0)
 * sass-listen (4.0.0)
 * sass (3.7.4)
 * tilt (2.0.10)
 * sass-rails (5.1.0)
 * sqlite3 (1.4.1)
 * turbolinks-source (5.2.0)
 * turbolinks (5.2.1)
 * webpacker (4.0.7)
Install missing gems with `bundle install`
cd /tmp/tomo-a4DBHX0P/20191019200138 && bundle install
The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run `bundle lock --add-platform x86-mingw32 x86-mswin32 x64-mingw32 java`.
Fetching gem metadata from https://rubygems.org/............
Fetching rake 13.0.0
Installing rake 13.0.0
Fetching thread_safe 0.3.6
Fetching concurrent-ruby 1.1.5
Fetching minitest 5.12.2
Installing minitest 5.12.2
Installing thread_safe 0.3.6
Installing concurrent-ruby 1.1.5
Fetching zeitwerk 2.2.0
Installing zeitwerk 2.2.0
Fetching builder 3.2.3
Fetching erubi 1.9.0
Installing builder 3.2.3
Installing erubi 1.9.0
Fetching mini_portile2 2.4.0
Installing mini_portile2 2.4.0
Fetching crass 1.0.4
Installing crass 1.0.4
Fetching rack 2.0.7
Installing rack 2.0.7
Fetching nio4r 2.5.2
Installing nio4r 2.5.2 with native extensions
Fetching websocket-extensions 0.1.4
Installing websocket-extensions 0.1.4
Fetching mimemagic 0.3.3
Installing mimemagic 0.3.3
Fetching mini_mime 1.0.2
Fetching msgpack 1.3.1
Installing mini_mime 1.0.2
Using bundler 2.0.2
Fetching ffi 1.11.1
Installing msgpack 1.3.1 with native extensions
Installing ffi 1.11.1 with native extensions
Fetching method_source 0.9.2
Installing method_source 0.9.2
Fetching puma 3.12.1
Installing puma 3.12.1 with native extensions
Fetching thor 0.20.3
Installing thor 0.20.3
Fetching rb-fsevent 0.10.3
Installing rb-fsevent 0.10.3
Fetching tilt 2.0.10
Installing tilt 2.0.10
Fetching sqlite3 1.4.1
Installing sqlite3 1.4.1 with native extensions
Fetching turbolinks-source 5.2.0
Installing turbolinks-source 5.2.0
Fetching tzinfo 1.2.5
Installing tzinfo 1.2.5
Fetching nokogiri 1.10.4
Installing nokogiri 1.10.4 with native extensions
Fetching i18n 1.7.0
Installing i18n 1.7.0
Fetching websocket-driver 0.7.1
Installing websocket-driver 0.7.1 with native extensions
Fetching marcel 0.3.3
Installing marcel 0.3.3
Fetching rack-test 1.1.0
Installing rack-test 1.1.0
Fetching rack-proxy 0.6.5
Installing rack-proxy 0.6.5
Fetching sprockets 3.7.2
Installing sprockets 3.7.2
Fetching mail 2.7.1
Installing mail 2.7.1
Fetching bootsnap 1.4.5
Installing bootsnap 1.4.5 with native extensions
Fetching rb-inotify 0.10.0
Installing rb-inotify 0.10.0
Fetching turbolinks 5.2.1
Installing turbolinks 5.2.1
Fetching activesupport 6.0.0
Installing activesupport 6.0.0
Fetching loofah 2.3.0
Installing loofah 2.3.0
Fetching sass-listen 4.0.0
Installing sass-listen 4.0.0
Fetching rails-html-sanitizer 1.3.0
Fetching sass 3.7.4
Fetching rails-dom-testing 2.0.3
Installing rails-html-sanitizer 1.3.0
Fetching globalid 0.4.2
Installing rails-dom-testing 2.0.3
Installing globalid 0.4.2
Installing sass 3.7.4
Fetching activemodel 6.0.0
Fetching jbuilder 2.9.1
Installing jbuilder 2.9.1
Installing activemodel 6.0.0
Fetching activejob 6.0.0
Installing activejob 6.0.0
Fetching actionview 6.0.0
Installing actionview 6.0.0
Fetching activerecord 6.0.0
Installing activerecord 6.0.0
Fetching actionpack 6.0.0
Installing actionpack 6.0.0
Fetching actioncable 6.0.0
Fetching actionmailer 6.0.0
Fetching railties 6.0.0
Installing actionmailer 6.0.0
Installing actioncable 6.0.0
Fetching sprockets-rails 3.2.1
Installing railties 6.0.0
Installing sprockets-rails 3.2.1
Fetching activestorage 6.0.0
Installing activestorage 6.0.0
Fetching actionmailbox 6.0.0
Fetching actiontext 6.0.0
Installing actionmailbox 6.0.0
Installing actiontext 6.0.0
Fetching sass-rails 5.1.0
Fetching rails 6.0.0
Fetching webpacker 4.0.7
Installing sass-rails 5.1.0
Installing rails 6.0.0
Installing webpacker 4.0.7
Bundle complete! 17 Gemfile dependencies, 59 gems now installed.
Gems in the groups development and test were not installed.
Bundled gems are installed into `/var/www/rails-new/shared/bundle`
Post-install message from i18n:

HEADS UP! i18n 1.1 changed fallbacks to exclude default locale.
But that may break your application.

Please check your Rails app for 'config.i18n.fallbacks = true'.
If you're using I18n (>= 1.1.0) and Rails (< 5.2.2), this should be
'config.i18n.fallbacks = [I18n.default_locale]'.
If not, fallbacks will be broken in your app by I18n 1.1.x.

For more info see:
https://github.com/svenfuchs/i18n/releases/tag/v1.1.0

Post-install message from sass:

Ruby Sass has reached end-of-life and should no longer be used.

* If you use Sass as a command-line tool, we recommend using Dart Sass, the new
  primary implementation: https://sass-lang.com/install

* If you use Sass as a plug-in for a Ruby web framework, we recommend using the
  sassc gem: https://github.com/sass/sassc-ruby#readme

* For more details, please refer to the Sass blog:
  https://sass-lang.com/blog/posts/7828841

• rails:db_create
cd /tmp/tomo-a4DBHX0P/20191019200138 && bundle exec rails db:version
Database already exists; skipping db:create.
• rails:db_schema_load
[ -f /tmp/tomo-a4DBHX0P/20191019200138/db/schema.rb ]
WARNING: db/schema.rb is not present; skipping schema:load.
• rails:db_seed
cd /tmp/tomo-a4DBHX0P/20191019200138 && bundle exec rails db:seed
• puma:setup_systemd
loginctl user-status deployer
mkdir -p .config/systemd/user
Writing 218 bytes to .config/systemd/user/puma_rails-new.socket
Writing 570 bytes to .config/systemd/user/puma_rails-new.service
systemctl --user daemon-reload
systemctl --user enable puma_rails-new.service puma_rails-new.socket
✔ Performed setup of rails-new on deployer@localhost:32829
```
