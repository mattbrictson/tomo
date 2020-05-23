module Tomo
  class Script
    attr_reader :script

    def initialize(script, echo: true, pty: false, raise_on_error: true, silent: false)
      @script = script
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

      @echo == true ? script : @echo
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
      script
    end
  end
end
