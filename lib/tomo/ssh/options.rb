module Tomo
  module SSH
    class Options
      DEFAULTS = {
        ssh_connect_timeout: 5,
        ssh_executable: "ssh".freeze,
        ssh_extra_opts: %w[-o PasswordAuthentication=no].map(&:freeze),
        ssh_forward_agent: true,
        ssh_reuse_connections: true,
        ssh_strict_host_key_checking: "accept-new".freeze
      }.freeze

      attr_reader :executable

      def initialize(options)
        DEFAULTS.merge(options).each do |attr, value|
          unprefixed_attr = attr.to_s.sub(/^ssh_/, "")
          send(:"#{unprefixed_attr}=", value)
        end
        freeze
      end

      def build_args(host, script, control_path, verbose) # rubocop:disable Metrics/AbcSize
        args = [verbose ? "-v" : ["-o", "LogLevel=ERROR"]]
        args << "-A" if forward_agent
        args << connect_timeout_option
        args << strict_host_key_checking_option
        args.push(*control_opts(control_path, verbose)) if reuse_connections
        args.push(*extra_opts) if extra_opts
        args << "-tt" if script.pty?
        args << host.to_ssh_args
        args << "--"

        [executable, args, script.to_s].flatten
      end

      private

      attr_writer :executable
      attr_accessor :connect_timeout, :extra_opts, :forward_agent, :reuse_connections, :strict_host_key_checking

      def control_opts(path, verbose)
        opts = [
          "-o",
          "ControlMaster=auto",
          "-o",
          "ControlPath=#{path}",
          "-o"
        ]
        opts << (verbose ? "ControlPersist=1s" : "ControlPersist=30s")
      end

      def connect_timeout_option
        return [] if connect_timeout.nil?

        ["-o", "ConnectTimeout=#{connect_timeout}"]
      end

      def strict_host_key_checking_option
        return [] if strict_host_key_checking.nil?

        value = case strict_host_key_checking
                when true then "yes"
                when false then "no"
                else strict_host_key_checking
                end

        ["-o", "StrictHostKeyChecking=#{value}"]
      end
    end
  end
end
