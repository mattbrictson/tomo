require_relative "nvm/tasks"

module Tomo::Plugin
  module Nvm
    extend Tomo::PluginDSL

    defaults bashrc_path: ".bashrc",
             nvm_version: "0.34.0",
             nvm_node_version: nil

    tasks Tomo::Plugin::Nvm::Tasks
  end
end
