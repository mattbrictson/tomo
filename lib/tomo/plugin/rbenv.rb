require_relative "rbenv/tasks"

module Tomo::Plugin
  module Rbenv
    extend Tomo::PluginDSL

    defaults bashrc_path: ".bashrc",
             rbenv_ruby_version: nil

    tasks Tomo::Plugin::Rbenv::Tasks
  end
end
