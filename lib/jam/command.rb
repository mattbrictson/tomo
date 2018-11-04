module Jam
  class Command
    attr_reader :command

    def initialize(command,
                   echo: true,
                   pty: false,
                   raise_on_error: true,
                   silent: false)
      @command = command
      @echo = echo
      @pty = pty
      @raise_on_error = raise_on_error
      @silent = silent
      freeze
    end

    def echo?
      !!@echo
    end

    def echo_string
      return nil unless echo?

      @echo == true ? command : @echo
    end

    def pty?
      !!@pty
    end

    def raise_on_error?
      !!@raise_on_error
    end

    def silent?
      !!@silent
    end

    def to_s
      command
    end
  end
end
