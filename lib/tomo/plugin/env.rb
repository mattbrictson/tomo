require_relative "env/tasks"

module Tomo::Plugin
  module Env
    extend Tomo::PluginDSL

    tasks Tomo::Plugin::Env::Tasks

    defaults bashrc_path: ".bashrc",
             env_path: "%{deploy_to}/envrc",
             env_vars: {}
  end
end
