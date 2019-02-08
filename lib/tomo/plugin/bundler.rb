require_relative "bundler/helpers"
require_relative "bundler/tasks"

module Tomo::Plugin
  module Bundler
    extend Tomo::PluginDSL

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
