require "shellwords"

module Tomo
  module SSH
    class ScriptError < Error
      attr_accessor :result, :script, :ssh_args

      def to_console
        msg = <<~ERROR
          The following script failed on #{yellow(host)} (exit status #{red(result.exit_status)}).

            #{yellow(script)}

          You can manually re-execute the script via SSH as follows:

            #{gray(ssh_args.map(&:shellescape).join(' '))}
        ERROR

        [msg, super].join("\n")
      end
    end
  end
end
