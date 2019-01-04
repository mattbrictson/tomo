require "shellwords"

module Tomo
  class ShellBuilder
    def initialize
      @env = {}
      @chdir = []
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

    def umask(mask)
      orig_umask = @umask
      @umask = mask
      yield
    ensure
      @umask = orig_umask
    end

    def build(*command, default_chdir: nil)
      if @chdir.empty? && default_chdir
        return chdir(default_chdir) { build(*command) }
      end

      command_string = shell_join(*command)
      prefixes = [cd_chdir, unset_env, export_env, set_umask].compact.flatten
      return command_string if prefixes.empty?

      "(#{[*prefixes, command_string].join(' && ')})"
    end

    private

    def shell_join(*command)
      command.flatten.compact.map(&:to_s).join(" ")
    end

    def cd_chdir
      @chdir.map { |dir| "cd #{dir.to_s.shellescape}" }
    end

    def unset_env
      unsets = @env.select { |_, value| value.nil? }
      return if unsets.empty?

      ["unset", *unsets.map(&:first)].join(" ")
    end

    def export_env
      exports = @env.reject { |_, value| value.nil? }
      return if exports.empty?

      [
        "export",
        *exports.map { |key, value| "#{key}=#{value.to_s.shellescape}" }
      ].join(" ")
    end

    def set_umask
      return if @umask.nil?

      umask_value = @umask.is_a?(Integer) ? @umask.to_s(8) : @umask
      "umask #{umask_value}"
    end
  end
end
