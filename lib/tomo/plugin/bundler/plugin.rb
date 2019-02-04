require_relative "helpers"
require_relative "tasks"

module Tomo::Plugin::Bundler
  module Plugin
    extend Tomo::Plugin

    tasks Tomo::Plugin::Bundler::Tasks
    helpers Tomo::Plugin::Bundler::Helpers

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
