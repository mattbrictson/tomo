require "forwardable"

module Tomo
  class Remote
    include TaskAPI

    extend Forwardable
    def_delegators :ssh, :close, :host
    def_delegators :shell_builder, :chdir, :env, :prepend, :umask

    attr_reader :release

    def initialize(ssh, context, helper_modules)
      @ssh = ssh
      @context = context
      @release = {}
      @shell_builder = ShellBuilder.new
      helper_modules.each { |mod| extend(mod) }
      freeze
    end

    def attach(*command, default_chdir: nil, **command_opts)
      full_command = shell_builder.build(*command, default_chdir: default_chdir)
      ssh.ssh_exec(Script.new(full_command, pty: true, **command_opts))
    end

    def run(*command, attach: false, default_chdir: nil, **command_opts)
      attach(*command, default_chdir: default_chdir, **command_opts) if attach

      full_command = shell_builder.build(*command, default_chdir: default_chdir)
      ssh.ssh_subprocess(Script.new(full_command, **command_opts))
    end

    private

    attr_reader :context, :ssh, :shell_builder

    def remote
      self
    end
  end
end
