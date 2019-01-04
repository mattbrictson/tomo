require_relative "helpers"
require_relative "tasks"

module Tomo::Plugins::Bundler
  module Plugin
    extend Tomo::Plugin

    tasks Tomo::Plugins::Bundler::Tasks
    helpers Tomo::Plugins::Bundler::Helpers

    defaults bundler_binstubs:      nil,
             bundler_clean_options: nil,
             bundler_env_variables: {},
             bundler_flags:         "--deployment",
             bundler_gemfile:       nil,
             bundler_jobs:          "4",
             bundler_path:          "%<shared_path>/bundle",
             bundler_without:       "development test"
  end
end
