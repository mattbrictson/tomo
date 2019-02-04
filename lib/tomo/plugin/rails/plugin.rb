require_relative "helpers"
require_relative "tasks"

module Tomo::Plugin::Rails
  module Plugin
    extend Tomo::Plugin

    helpers Tomo::Plugin::Rails::Helpers
    tasks Tomo::Plugin::Rails::Tasks
  end
end
