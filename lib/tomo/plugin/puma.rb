require_relative "puma/tasks"

module Tomo::Plugin
  module Puma
    extend Tomo::PluginDSL

    tasks Tomo::Plugin::Puma::Tasks

    defaults puma_control_token: "tomo",
             puma_control_url: "tcp://127.0.0.1:9293"
  end
end
