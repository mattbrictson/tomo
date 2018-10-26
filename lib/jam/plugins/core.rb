module Jam
  module Plugins
    class Core
      autoload :Helpers, "jam/plugins/core/helpers"

      extend Jam::Plugin
      helpers Jam::Plugins::Core::Helpers
    end
  end
end
