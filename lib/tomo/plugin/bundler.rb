require_relative "bundler/helpers"
require_relative "bundler/tasks"

module Tomo::Plugin
  module Bundler
    extend Tomo::PluginDSL

    tasks Tomo::Plugin::Bundler::Tasks
    helpers Tomo::Plugin::Bundler::Helpers

    defaults bundler_config_path:     ".bundle/config",
             bundler_deployment:      true,
             bundler_gemfile:         nil,
             bundler_ignore_messages: true,
             bundler_jobs:            nil,
             bundler_path:            "%{shared_path}/bundle",
             bundler_retry:           "3",
             bundler_version:         nil,
             bundler_without:         %w[development test]
  end
end
