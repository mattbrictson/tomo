require "open3"

module Tomo
  VERSION = "0.16.0".extend(Module.new do
    attr_accessor :major, :minor, :patch, :git_sha, :with_git_sha
  end)

  VERSION.major,
  VERSION.minor,
  VERSION.patch, = Gem::Version.new(VERSION).segments

  VERSION.git_sha = \
    begin
      gem_dir = File.expand_path("../..", __dir__)
      if Dir.exist?(File.join(gem_dir, ".git"))
        Dir.chdir(gem_dir) do
          out, status = Open3.capture2e("git rev-parse --verify --short HEAD")
          out.chomp if status.success?
        end
      end
    rescue StandardError
      nil
    end.freeze

  VERSION.with_git_sha = if VERSION.git_sha
                           "#{VERSION} (#{VERSION.git_sha})".freeze
                         else
                           VERSION
                         end
  VERSION.freeze
end
