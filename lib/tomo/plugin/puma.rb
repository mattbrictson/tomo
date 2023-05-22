require_relative "puma/tasks"

module Tomo::Plugin
  module Puma
    extend Tomo::PluginDSL

    tasks Tomo::Plugin::Puma::Tasks
    defaults puma_check_timeout: 15,
             puma_host: "0.0.0.0",
             puma_port: "3000",
             puma_systemd_service: "puma_%{application}.service",
             puma_systemd_socket: "puma_%{application}.socket",
             puma_systemd_service_type: "notify",
             puma_systemd_service_path: ".config/systemd/user/%{puma_systemd_service}",
             puma_systemd_socket_path: ".config/systemd/user/%{puma_systemd_socket}",
             puma_systemd_service_template_path: File.expand_path("puma/systemd/service.erb", __dir__),
             puma_systemd_socket_template_path: File.expand_path("puma/systemd/socket.erb", __dir__)
  end
end
