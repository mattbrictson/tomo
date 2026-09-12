# frozen_string_literal: true

require_relative "direct/helpers"
require_relative "direct/tasks"

module Tomo::Plugin
  module Direct
    extend Tomo::PluginDSL

    helpers Tomo::Plugin::Direct::Helpers
    tasks Tomo::Plugin::Direct::Tasks
    defaults direct_source_path: nil,
             direct_exclusions: nil
  end
end
