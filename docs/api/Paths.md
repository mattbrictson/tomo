# Tomo::Paths

Provides syntactic sugar for accessing settings that represent file system paths. For every tomo setting in the form `:<name>_path`, Paths will expose a method of that name that behaves like a Ruby Pathname object. As a special exception, the `:deploy_to` setting is also exposed even though it does not follow the same naming convention.

In tomo the following path settings are always available:

```ruby
settings[:deploy_to]     # => "/var/www/my-app"
settings[:current_path]  # => "/var/www/my-app/current"
settings[:release_path]  # => "/var/www/my-app/releases/20190531164322"
settings[:releases_path] # => "/var/www/my-app/releases"
settings[:shared_path]   # => "/var/www/my-app/shared"
```

Using Paths, these same settings can be accessed like this:

```ruby
paths.deploy_to # => "/var/www/my-app"
paths.current   # => "/var/www/my-app/current"
paths.release   # => "/var/www/my-app/releases/20190531164322"
paths.releases  # => "/var/www/my-app/releases"
paths.shared    # => "/var/www/my-app/shared"
```

More powerfully, the values returned by Paths respond to `join` and `dirname`, so you can easily compose them:

```ruby
paths.current.dirname       # => "/var/www/my-app"
paths.release.join("tmp")   # => "/var/www/my-app/releases/20190531164322/tmp"
paths.shared.join("bundle") # => "/var/www/my-app/shared/bundle"
```

Paths can be used wherever a path string is expected, like [chdir](Remote.md#chdirdir-block-obj):

```ruby
remote.chdir(paths.current) do
  remote.run("bundle", "exec", "puma", "--daemon")
end
# $ cd /var/www/my-app/current && bundle exec puma --daemon
```

If a plugin defines a setting with the suffix `_path` or if you create your own setting with that suffix, it automatically will be exposed via the Paths object:

```ruby
# .tomo/config.rb
set my_custom_path: "/opt/custom"
```

```ruby
paths.my_custom.join("var") # => "/opt/custom/var"
```
