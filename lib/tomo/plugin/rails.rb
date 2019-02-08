require_relative "rails/helpers"
require_relative "rails/tasks"

module Tomo::Plugin
  module Rails
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Rails::Helpers
    tasks Tomo::Plugin::Rails::Tasks
  end
end
