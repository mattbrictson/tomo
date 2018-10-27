require_relative "helpers"
require_relative "tasks"

module Jam::Plugins::Bundler
  module Plugin
    extend Jam::Plugin

    tasks Jam::Plugins::Bundler::Tasks
    helpers Jam::Plugins::Bundler::Helpers

    defaults bundler_binstubs:      nil,
             bundler_clean_options: "",
             bundler_env_variables: {},
             bundler_flags:         "--deployment",
             bundler_gemfile:       nil,
             bundler_jobs:          "4",
             bundler_path:          "%<shared_path>/bundle",
             bundler_without:       "development test"
  end
end
