module Tomo
  module Plugins
    autoload :Bundler, "tomo/plugins/bundler/plugin"
    autoload :Core, "tomo/plugins/core/plugin"
    autoload :Git, "tomo/plugins/git/plugin"
    autoload :Rails, "tomo/plugins/rails/plugin"
  end
end
