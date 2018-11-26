require "shellwords"

module Jam
  module SSH
    class ScriptError < Error
      attr_accessor :result, :script, :ssh_args

      def to_console
        msg = <<~ERROR
          Script failed to run on #{yellow(host)} (exit status #{red(result.exit_status)}).

          You can manually re-execute the script via SSH as follows:

          #{gray(ssh_args.map(&:shellescape).join(' '))}
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
