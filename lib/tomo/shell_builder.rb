require "shellwords"

module Tomo
  class ShellBuilder
    def self.raw(string)
      string.dup.tap do |raw_string|
        raw_string.define_singleton_method(:shellescape) { string }
      end
    end

    def initialize
      @env = {}
      @chdir = []
      @prefixes = []
      @umask = nil
    end

    def chdir(dir)
      @chdir << dir
      yield
    ensure
      @chdir.pop
    end

    def env(hash)
      orig_env = @env
      @env = orig_env.merge(hash || {})
      yield
    ensure
      @env = orig_env
    end

    def prepend(*command)
      prefixes.unshift(*command)
      yield
    ensure
      prefixes.shift(command.length)
    end

    def umask(mask)
      orig_umask = @umask
      @umask = mask
      yield
    ensure
      @umask = orig_umask
    end

    def build(*command, default_chdir: nil)
      return chdir(default_chdir) { build(*command) } if @chdir.empty? && default_chdir

      command_string = command_to_string(*command)
      modifiers = [cd_chdir, unset_env, export_env, set_umask].compact.flatten
      [*modifiers, command_string].join(" && ")
    end

    private

    attr_reader :prefixes

    def command_to_string(*command)
      command_string = shell_join(*command)
      return command_string if prefixes.empty?

      "#{shell_join(*prefixes)} #{command_string}"
    end

    def shell_join(*command)
      return command.first.to_s if command.length == 1

      command.flatten.compact.map { |arg| arg.to_s.shellescape }.join(" ")
    end

    def cd_chdir
      @chdir.map { |dir| "cd #{dir.to_s.shellescape}" }
    end

    def unset_env
      unsets = @env.select { |_, value| value.nil? }
      return if unsets.empty?

      ["unset", *unsets.map { |entry| entry.first.to_s.shellescape }].join(" ")
    end

    def export_env
      exports = @env.compact
      return if exports.empty?

      [
        "export",
        *exports.map do |key, value|
          "#{key.to_s.shellescape}=#{value.to_s.shellescape}"
        end
      ].join(" ")
    end

    def set_umask
      return if @umask.nil?

      umask_value = @umask.is_a?(Integer) ? @umask.to_s(8).rjust(4, "0") : @umask
      "umask #{umask_value.to_s.shellescape}"
    end
  end
end
