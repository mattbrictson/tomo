require "shellwords"

module Jam
  module SSH
    class ScriptError < Error
      attr_accessor :result, :script, :ssh_args

      def to_console
        <<~ERROR
          Remote command failed on #{yellow(host)} (exit status #{red(result.exit_status)}).

          You can manually retry the command by running the following:

          #{gray(ssh_args.map(&:shellescape).join(' '))}
        ERROR
      end
    end
  end
end
