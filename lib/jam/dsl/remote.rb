require "forwardable"
require "shellwords"

module Jam
  module DSL
    class Remote
      extend Forwardable
      def_delegators :ssh, :host

      include Jam::DSL

      def initialize(ssh, helpers: [])
        @ssh = ssh
        @prefixes = []
        helpers.each { |mod| extend(mod) }
        freeze
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def prepend(*args)
        raise ArgumentError, "prepend requires an argument" if args.empty?
        raise ArgumentError, "prepend must be given a block" unless block_given?

        begin
          if args.length == 1
            prefixes.push(raw(args.first))
          else
            prefixes.push(*args)
          end
          yield
        ensure
          prefixes.pop(args.count)
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def attach(command, *args, echo: true)
        command_string = shell_join(command, *args)
        log(command_string, echo) if echo
        ssh.attach(command_string)
      end

      # rubocop:disable Metrics/ParameterLists
      def run(command, *args,
              echo: true,
              silent: false,
              pty: false,
              raise_on_error: true)
        command_string = shell_join(command, *args)
        log(command_string, echo) if echo
        ssh.run(
          command_string,
          silent: silent,
          pty: pty,
          raise_on_error: raise_on_error
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def run?(command, *args, **run_opts)
        result = run(command, *args, **run_opts.merge(raise_on_error: false))
        result.success?
      end

      private

      attr_reader :ssh, :prefixes

      def log(command_string, echo)
        puts(echo == true ? "\e[0;90;49m#{host}$ #{command_string}\e[0m" : echo)
      end

      def shell_join(command, *args)
        safe = prefixes.map(&:shellescape)
        if args.empty? && !command.is_a?(Array)
          safe << command
        else
          safe.append(*[command, *args].flatten.map(&:shellescape))
        end
        safe.join(" ")
      end
    end
  end
end
