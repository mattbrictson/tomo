module Jam
  class Project
    class NotFoundError < Jam::Error
      attr_accessor :path

      def to_console
        <<~ERROR
          A #{yellow(path)} configuration file is required to run this command.
          Are you in the right directory?

          To create a new #{yellow(path)} file, run #{blue('jam init')}.
        ERROR
      end
    end
  end
end
