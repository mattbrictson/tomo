require_relative "nodenv/tasks"

module Tomo::Plugin
  module Nodenv
    extend Tomo::PluginDSL

    defaults bashrc_path: ".bashrc",
             nodenv_install_yarn: true,
             nodenv_node_version: nil,
             nodenv_yarn_version: nil

    tasks Tomo::Plugin::Nodenv::Tasks
  end
end
