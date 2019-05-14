module Tomo
  module SSH
    class Options
      attr_reader :executable

      def initialize(settings)
        @executable = settings.fetch(:ssh_executable)
        @extra_opts = settings.fetch(:ssh_extra_opts)
        @forward_agent = settings.fetch(:ssh_forward_agent)
        @reuse_connections = settings.fetch(:ssh_reuse_connections)
        @connect_timeout = settings.fetch(:ssh_connect_timeout)
        @strict_host_key_checking = settings.fetch(
          :ssh_strict_host_key_checking
        )
        freeze
      end

      # rubocop:disable Metrics/AbcSize
      def build_args(host, script, control_path, verbose)
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
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :connect_timeout, :extra_opts, :forward_agent,
                  :reuse_connections, :strict_host_key_checking

      def control_opts(path, verbose)
        opts = [
          "-o", "ControlMaster=auto",
          "-o", "ControlPath=#{path}",
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
