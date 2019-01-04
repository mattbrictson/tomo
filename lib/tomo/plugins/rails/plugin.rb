require_relative "helpers"
require_relative "tasks"

module Tomo::Plugins::Rails
  module Plugin
    extend Tomo::Plugin

    helpers Tomo::Plugins::Rails::Helpers
    tasks Tomo::Plugins::Rails::Tasks
  end
end
