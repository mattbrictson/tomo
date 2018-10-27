require_relative "helpers"
require_relative "tasks"

module Jam::Plugins::Rails
  module Plugin
    extend Jam::Plugin

    helpers Jam::Plugins::Rails::Helpers
    tasks Jam::Plugins::Rails::Tasks
  end
end
