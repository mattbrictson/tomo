module Jam
  module Plugins
    autoload :Bundler, "jam/plugins/bundler/plugin"
    autoload :Core, "jam/plugins/core/plugin"
    autoload :Git, "jam/plugins/git/plugin"
    autoload :Rails, "jam/plugins/rails/plugin"
  end
end
