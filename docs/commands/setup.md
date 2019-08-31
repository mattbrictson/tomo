# setup

Prepare the current project for its first deploy.

## Usage

```plain
$ tomo setup [--dry-run] [options]
```

Prepare the remote host for its first deploy by sequentially running the
[setup](../configuration.md#setupblock) list of tasks specified in `.tomo/config.rb`. These tasks typically create directories, initialize data stores, install prerequisite tools, and perform other one-time actions that are necessary before a deploy can take place.

During setup, tomo will initialize the `:release_path` setting to be a temporary directory based on the current date and time (e.g. `/tmp/tomo/20190616214752`). This means setup tasks (e.g. [rails:db_create](../plugins/rails.md#railsdb_create), [rails:db_schema_load](../plugins/rails.md#railsdb_schema_load)) run in a location that won't be deployed as an actual release.

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
end
```

Then a setup would produce:

```plain
$ tomo setup
tomo setup v0.1.0
→ Connecting to deployer@localhost:32809
• env:setup
Writing 280 bytes to /var/www/rails-new/envrc
cat .bashrc
Writing 3845 bytes to .bashrc
• core:setup_directories
mkdir -p /var/www/rails-new /var/www/rails-new/releases /var/www/rails-new/shared
• git:clone
[ -d /var/www/rails-new/git_repo ]
mkdir -p /var/www/rails-new
export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git clone --mirror git@github.com:mattbrictson/rails-new.git /var/www/rails-new/git_repo
Cloning into bare repository '/var/www/rails-new/git_repo'...
Warning: Permanently added 'github.com,192.30.255.112' (RSA) to the list of known hosts.
• git:create_release
Writing 60 bytes to /var/www/rails-new/git_repo/info/attributes
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git remote update --prune
Fetching origin
cd /var/www/rails-new/git_repo && mkdir -p /tmp/tomo/20190616214334
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git archive master | tar -x -f - -C /tmp/tomo/20190616214334
cd /var/www/rails-new/git_repo && export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication\=no\ -o\ StrictHostKeyChecking\=no && git log -n1 --date=iso --pretty=format:"%H/%cd/%ae" master
• core:symlink_shared
mkdir -p /var/www/rails-new/shared/.bundle /var/www/rails-new/shared/log /var/www/rails-new/shared/node_modules /var/www/rails-new/shared/public/assets /tmp/tomo/20190616214334/public
cd /tmp/tomo/20190616214334 && rm -rf .bundle log node_modules public/assets
ln -sf /var/www/rails-new/shared/.bundle /tmp/tomo/20190616214334/.bundle
ln -sf /var/www/rails-new/shared/log /tmp/tomo/20190616214334/log
ln -sf /var/www/rails-new/shared/node_modules /tmp/tomo/20190616214334/node_modules
ln -sf /var/www/rails-new/shared/public/assets /tmp/tomo/20190616214334/public/assets
• nodenv:install
export PATH=$HOME/.nodenv/bin:$HOME/.nodenv/shims:$PATH && curl -fsSL https://github.com/nodenv/nodenv-installer/raw/master/bin/nodenv-installer | bash
Installing nodenv with git...
Initialized empty Git repository in /home/deployer/.nodenv/.git/
Updating origin
From https://github.com/nodenv/nodenv
 * [new branch]      master     -> origin/master
 * [new tag]         v1.3.0     -> v1.3.0
 * [new tag]         0.2.0      -> 0.2.0
 * [new tag]         v0.1.0     -> v0.1.0
 * [new tag]         v0.2.0     -> v0.2.0
 * [new tag]         v0.3.0     -> v0.3.0
 * [new tag]         v0.4.0     -> v0.4.0
 * [new tag]         v1.0.0     -> v1.0.0
 * [new tag]         v1.1.0     -> v1.1.0
 * [new tag]         v1.1.1     -> v1.1.1
 * [new tag]         v1.1.2     -> v1.1.2
Branch 'master' set up to track remote branch 'master' from 'origin'.
 * [new tag]         v1.2.0     -> v1.2.0
make: Entering directory '/home/deployer/.nodenv/src'
Already on 'master'
Cloning into '/home/deployer/.nodenv/plugins/node-build'...
gcc -fPIC     -c -o realpath.o realpath.c
gcc -shared -Wl,-soname,../libexec/nodenv-realpath.dylib  -o ../libexec/nodenv-realpath.dylib realpath.o
make: Leaving directory '/home/deployer/.nodenv/src'

Installing node-build with git...

Running doctor script to verify installation...
Checking for `nodenv' in PATH: /home/deployer/.nodenv/bin/nodenv
Checking for nodenv shims in PATH: OK
Checking `nodenv install' support: /home/deployer/.nodenv/plugins/node-build/bin/nodenv-install (node-build 4.6.2)
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
Writing 3962 bytes to .bashrc
nodenv versions
Installing node 10.16.0 -- this may take several minutes
CFLAGS=-O3 nodenv install 10.16.0
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LC_CTYPE = "en_GB.UTF-8",
	LC_TERMINAL = "iTerm2",
	LC_TERMINAL_VERSION = "3.3.20190722-nightly",
	LANG = "C.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to a fallback locale ("C.UTF-8").
Downloading node-v10.16.0-linux-x64.tar.gz...
-> https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-x64.tar.gz
Installing node-v10.16.0-linux-x64...
Installed node-v10.16.0-linux-x64 to /home/deployer/.nodenv/versions/10.16.0

nodenv global 10.16.0
npm i -g yarn@1.17.3
/home/deployer/.nodenv/versions/10.16.0/bin/yarn -> /home/deployer/.nodenv/versions/10.16.0/lib/node_modules/yarn/bin/yarn.js
/home/deployer/.nodenv/versions/10.16.0/bin/yarnpkg -> /home/deployer/.nodenv/versions/10.16.0/lib/node_modules/yarn/bin/yarn.js
+ yarn@1.17.3
added 1 package in 0.341s
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
Checking `rbenv install' support: /home/deployer/.rbenv/plugins/ruby-build/bin/rbenv-install (ruby-build 20190615-1-g0867187)
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
Writing 4121 bytes to .bashrc
rbenv versions
Installing ruby 2.6.3 -- this may take several minutes
CFLAGS=-O3 rbenv install 2.6.3
Downloading ruby-2.6.3.tar.bz2...
-> https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.3.tar.bz2
Installing ruby-2.6.3...
Installed ruby-2.6.3 to /home/deployer/.rbenv/versions/2.6.3

rbenv global 2.6.3
• bundler:upgrade_bundler
tail -n 10 /tmp/tomo/20190616214334/Gemfile.lock
gem install bundler --conservative --no-document -v 2.0.1
Successfully installed bundler-2.0.1
1 gem installed
• bundler:install
cd /tmp/tomo/20190616214334 && bundle check --path /var/www/rails-new/shared/bundle
The following gems are missing
 * rake (12.3.2)
 * concurrent-ruby (1.1.5)
 * i18n (1.6.0)
 * minitest (5.11.3)
 * thread_safe (0.3.6)
 * tzinfo (1.2.5)
 * zeitwerk (2.1.6)
 * activesupport (6.0.0.rc1)
 * builder (3.2.3)
 * erubi (1.8.0)
 * mini_portile2 (2.4.0)
 * nokogiri (1.10.3)
 * rails-dom-testing (2.0.3)
 * crass (1.0.4)
 * loofah (2.2.3)
 * rails-html-sanitizer (1.0.4)
 * actionview (6.0.0.rc1)
 * rack (2.0.7)
 * rack-test (1.1.0)
 * actionpack (6.0.0.rc1)
 * nio4r (2.3.1)
 * websocket-extensions (0.1.3)
 * websocket-driver (0.7.0)
 * actioncable (6.0.0.rc1)
 * globalid (0.4.2)
 * activejob (6.0.0.rc1)
 * activemodel (6.0.0.rc1)
 * activerecord (6.0.0.rc1)
 * mimemagic (0.3.3)
 * marcel (0.3.3)
 * activestorage (6.0.0.rc1)
 * mini_mime (1.0.1)
 * mail (2.7.1)
 * actionmailbox (6.0.0.rc1)
 * actionmailer (6.0.0.rc1)
 * actiontext (6.0.0.rc1)
 * public_suffix (3.0.3)
 * addressable (2.6.0)
 * bindex (0.7.0)
 * msgpack (1.2.10)
 * bootsnap (1.4.4)
 * byebug (11.0.1)
 * regexp_parser (1.5.0)
 * execjs (2.7.0)
 * uglifier (4.1.20)
 * xpath (3.2.0)
 * capybara (3.20.0)
 * childprocess (1.0.1)
 * ffi (1.10.0)
 * jbuilder (2.9.1)
 * rb-fsevent (0.10.3)
 * rb-inotify (0.10.0)
 * ruby_dep (1.5.0)
 * listen (3.1.5)
 * method_source (0.9.2)
 * puma (3.12.1)
 * rack-proxy (0.6.5)
 * thor (0.20.3)
 * railties (6.0.0.rc1)
 * sprockets (3.7.2)
 * sprockets-rails (3.2.1)
 * rails (6.0.0.rc1)
 * rubyzip (1.2.2)
 * sass-listen (4.0.0)
 * sass (3.7.4)
 * tilt (2.0.9)
 * sass-rails (5.0.7)
 * selenium-webdriver (3.142.2)
 * spring (2.0.2)
 * spring-watcher-listen (2.0.1)
 * sqlite3 (1.4.1)
 * turbolinks-source (5.2.0)
 * turbolinks (5.2.0)
 * web-console (4.0.0)
 * webdrivers (3.9.2)
 * webpacker (4.0.2)
Install missing gems with `bundle install`
cd /tmp/tomo/20190616214334 && bundle install --path /var/www/rails-new/shared/bundle --jobs 4 --without development test --deployment
Fetching gem metadata from https://rubygems.org/............
Fetching rake 12.3.2
Installing rake 12.3.2
Fetching concurrent-ruby 1.1.5
Fetching minitest 5.11.3
Fetching thread_safe 0.3.6
Installing minitest 5.11.3
Installing thread_safe 0.3.6
Installing concurrent-ruby 1.1.5
Fetching zeitwerk 2.1.6
Installing zeitwerk 2.1.6
Fetching builder 3.2.3
Installing builder 3.2.3
Fetching erubi 1.8.0
Installing erubi 1.8.0
Fetching mini_portile2 2.4.0
Fetching crass 1.0.4
Installing mini_portile2 2.4.0
Fetching rack 2.0.7
Fetching nio4r 2.3.1
Installing crass 1.0.4
Fetching websocket-extensions 0.1.3
Installing websocket-extensions 0.1.3
Fetching mimemagic 0.3.3
Installing nio4r 2.3.1 with native extensions
Installing rack 2.0.7
Installing mimemagic 0.3.3
Fetching mini_mime 1.0.1
Installing mini_mime 1.0.1
Fetching msgpack 1.2.10
Using bundler 2.0.1
Fetching ffi 1.10.0
Installing msgpack 1.2.10 with native extensions
Installing ffi 1.10.0 with native extensions
Fetching method_source 0.9.2
Installing method_source 0.9.2
Fetching puma 3.12.1
Installing puma 3.12.1 with native extensions
Fetching thor 0.20.3
Installing thor 0.20.3
Fetching rb-fsevent 0.10.3
Installing rb-fsevent 0.10.3
Fetching tilt 2.0.9
Installing tilt 2.0.9
Fetching sqlite3 1.4.1
Installing sqlite3 1.4.1 with native extensions
Fetching turbolinks-source 5.2.0
Installing turbolinks-source 5.2.0
Fetching tzinfo 1.2.5
Installing tzinfo 1.2.5
Fetching nokogiri 1.10.3
Installing nokogiri 1.10.3 with native extensions
Fetching i18n 1.6.0
Installing i18n 1.6.0
Fetching websocket-driver 0.7.0
Installing websocket-driver 0.7.0 with native extensions
Fetching marcel 0.3.3
Installing marcel 0.3.3
Fetching mail 2.7.1
Installing mail 2.7.1
Fetching rack-test 1.1.0
Installing rack-test 1.1.0
Fetching rack-proxy 0.6.5
Installing rack-proxy 0.6.5
Fetching sprockets 3.7.2
Installing sprockets 3.7.2
Fetching bootsnap 1.4.4
Installing bootsnap 1.4.4 with native extensions
Fetching rb-inotify 0.10.0
Installing rb-inotify 0.10.0
Fetching turbolinks 5.2.0
Installing turbolinks 5.2.0
Fetching activesupport 6.0.0.rc1
Installing activesupport 6.0.0.rc1
Fetching loofah 2.2.3
Installing loofah 2.2.3
Fetching sass-listen 4.0.0
Fetching rails-html-sanitizer 1.0.4
Fetching rails-dom-testing 2.0.3
Installing sass-listen 4.0.0
Fetching globalid 0.4.2
Installing rails-html-sanitizer 1.0.4
Fetching activemodel 6.0.0.rc1
Installing rails-dom-testing 2.0.3
Fetching jbuilder 2.9.1
Installing globalid 0.4.2
Fetching sass 3.7.4
Installing activemodel 6.0.0.rc1
Installing jbuilder 2.9.1
Fetching actionview 6.0.0.rc1
Installing sass 3.7.4
Installing actionview 6.0.0.rc1
Fetching activejob 6.0.0.rc1
Installing activejob 6.0.0.rc1
Fetching activerecord 6.0.0.rc1
Installing activerecord 6.0.0.rc1
Fetching actionpack 6.0.0.rc1
Installing actionpack 6.0.0.rc1
Fetching actioncable 6.0.0.rc1
Fetching actionmailer 6.0.0.rc1
Fetching railties 6.0.0.rc1
Installing actionmailer 6.0.0.rc1
Installing actioncable 6.0.0.rc1
Fetching sprockets-rails 3.2.1
Fetching activestorage 6.0.0.rc1
Installing sprockets-rails 3.2.1
Installing activestorage 6.0.0.rc1
Installing railties 6.0.0.rc1
Fetching actionmailbox 6.0.0.rc1
Fetching actiontext 6.0.0.rc1
Installing actiontext 6.0.0.rc1
Installing actionmailbox 6.0.0.rc1
Fetching sass-rails 5.0.7
Fetching rails 6.0.0.rc1
Fetching webpacker 4.0.2
Installing sass-rails 5.0.7
Installing rails 6.0.0.rc1
Installing webpacker 4.0.2
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
cd /tmp/tomo/20190616214334 && bundle exec rails db:version
Database already exists; skipping db:create.
• rails:db_schema_load
[ -f /tmp/tomo/20190616214334/db/schema.rb ]
WARNING: db/schema.rb is not present; skipping schema:load.
• rails:db_seed
cd /tmp/tomo/20190616214334 && bundle exec rails db:seed
✔ Performed setup of rails-new on deployer@localhost:32809
```
