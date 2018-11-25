module Jam
  module SSH
    class Options
      attr_reader :executable

      def initialize(settings)
        @executable = settings.fetch(:ssh_executable)
        @extra_opts = settings.fetch(:ssh_extra_opts)
        @forward_agent = settings.fetch(:ssh_forward_agent)
        @reuse_connections = settings.fetch(:ssh_reuse_connections)
        freeze
      end

      # rubocop:disable Metrics/AbcSize
      def build_args(host, script, control_path, verbose)
        args = [verbose ? "-v" : ["-o", "LogLevel=ERROR"]]
        args << "-A" if forward_agent
        args.push(*control_opts(control_path, verbose)) if reuse_connections
        args.push(*extra_opts) if extra_opts
        args << "-tt" if script.pty?
        args << host.to_ssh_args
        args << "--"

        [executable, args, script.to_s].flatten
      end
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :extra_opts, :forward_agent, :reuse_connections

      def control_opts(path, verbose)
        opts = [
          "-o", "ControlMaster=auto",
          "-o", "ControlPath=#{path}",
          "-o"
        ]
        opts << (verbose ? "ControlPersist=1s" : "ControlPersist=30s")
      end
    end
  end
end
