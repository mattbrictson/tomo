# Tomo::PluginDSL

A tomo plugin is defined by a Ruby module that extends Tomo::PluginDSL. A plugin definition can specify three things:

- Default settings
- Tasks
- Helpers

Here is the bundler plugin as an example:

```ruby
require_relative "bundler/helpers"
require_relative "bundler/tasks"

module Tomo::Plugin::Bundler
  extend Tomo::PluginDSL

  tasks Tomo::Plugin::Bundler::Tasks
  helpers Tomo::Plugin::Bundler::Helpers

  defaults bundler_install_flags: ["--deployment"],
           bundler_gemfile:       nil,
           bundler_jobs:          "4",
           bundler_path:          "%<shared_path>/bundle",
           bundler_without:       %w[development test]
end
```

The above plugin defines several default settings, defines tasks using a [TaskLibrary](TaskLibrary.md) named `Tomo::Plugin::Bundler::Tasks`, and defines helpers in a module named `Tomo::Plugin::Bundler::Helpers`.

Refer to the [Publishing a Plugin](../tutorials/publishing-a-plugin.md) tutorial for more information about packaging and distributing tomo plugins.

## Instance methods

### defaults(hash)

Specify default settings that will be applied when this plugin is loaded. Although not strictly necessary, it is best practice to list all required and optional settings that are used by the plugin, even if the default values are `nil`. This lets other developers know what setting names are expected when using the plugin.

Settings must use symbol keys and typically String values, although any Ruby type is possible. Strings can contain [interpolated values](../configuration.md#interpolation).

```ruby
module Tomo::Plugin::Bundler
  extend Tomo::PluginDSL

  defaults bundler_install_flags: ["--deployment"],
           bundler_gemfile:       nil,
           bundler_jobs:          "4",
           bundler_path:          "%<shared_path>/bundle",
           bundler_without:       %w[development test]
end
```

### tasks(\*task_library_class)

Specify the tasks that will be defined by this plugin by supplying one or more [TaskLibrary](TaskLibrary.md) classes. The public instance methods of each class will be turned into tomo tasks.

```ruby
class Tomo::Plugin::Git::Tasks < Tomo::TaskLibrary
  def clone
    # ...
  end

  def create_release
    # ...
  end
end

class Tomo::Plugin::Git
  extend Tomo::PluginDSL

  tasks Tomo::Plugin::Git::Tasks
end
```

You can use `self` to define a plugin and its tasks together as a single class:

```ruby
class Tomo::Plugin::Git < Tomo::TaskLibrary
  extend Tomo::PluginDSL
  tasks self

  def clone
    # ...
  end

  def create_release
    # ...
  end
end
```

### helpers(\*module)

Specify the helpers that will be defined by this plugin by supplying one or more plain Ruby modules. The modules will be mixed in at runtime to extend the [Remote](Remote.md) interface with additional methods.

```ruby
module Tomo::Plugin::Core::Helpers
  def ln_sf(target, link, **run_opts)
    # ...
  end

  def mkdir_p(*directories, **run_opts)
    # ...
  end
end

module Tomo::Plugin::Core
  extend Tomo::PluginDSL

  helpers Tomo::Plugin::Core::Helpers
end
```
