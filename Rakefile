require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: %i[test rubocop]
desc "Run all tests"
task test: %w[test:unit test:docker]

RuboCop::RakeTask.new

Rake::TestTask.new("test:unit") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"] -
                 FileList["test/**/*_e2e_test.rb"] -
                 FileList["test/**/*_docker_test.rb"]
end

if system("docker version > /dev/null")
  Rake::TestTask.new("test:docker") do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_docker_test.rb"]
  end
  Rake::TestTask.new("test:e2e") do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_e2e_test.rb"]
  end
else
  task "test:docker" do
    warn "!!\n!! docker not available; docker tests will be skipped.\n!!"
  end
  task "test:e2e" do
    warn "!!\n!! docker not available; e2e tests will be skipped.\n!!"
  end
end

task bump: %w[bump:bundler bump:ruby bump:year]

Rake::Task["release"].enhance do
  puts "Don't forget publish the release on GitHub!"
  system "open https://github.com/mattbrictson/tomo/releases"
end

namespace :bump do
  task :bundler do
    version = Gemfile.bundler_version
    replace_in_file ".travis.yml", /bundler -v (\S+)/ => version
    replace_in_file ".circleci/config.yml", /bundler -v (\S+)/ => version
    replace_in_file ".circleci/Dockerfile", /bundler -v (\S+)/ => version
  end

  task :ruby do
    lowest = RubyVersions.lowest_supported
    lowest_minor = RubyVersions.lowest_supported_minor
    latest = RubyVersions.latest

    replace_in_file "tomo.gemspec", /ruby_version = ">= (.*)"/ => lowest
    replace_in_file ".rubocop.yml", /TargetRubyVersion: (.*)/ => lowest_minor
    replace_in_file ".circleci/config.yml",
                    %r{circleci/ruby:([\d\.]+)} => latest
    replace_in_file ".circleci/Dockerfile",
                    %r{circleci/ruby:([\d\.]+)} => latest
    replace_in_file "docs/comparisons.md",
                    /ruby version\s*\|\s*([\d\.]+)/i => lowest_minor

    travis = YAML.safe_load(open(".travis.yml"))
    travis["rvm"] = RubyVersions.latest_supported_patches + ["ruby-head"]
    IO.write(".travis.yml", YAML.dump(travis))
  end

  task :year do
    replace_in_file "LICENSE.txt", /\(c\) (\d+)/ => Date.today.year.to_s
  end
end

require "date"
require "open-uri"
require "yaml"

def replace_in_file(path, replacements)
  contents = IO.read(path)
  orig_contents = contents.dup
  replacements.each do |regexp, text|
    contents.gsub!(regexp) do |match|
      match[regexp, 1] = text
      match
    end
  end
  IO.write(path, contents) if contents != orig_contents
end

module Gemfile
  class << self
    def bundler_version
      lock_file[/BUNDLED WITH\n   (\S+)$/, 1]
    end

    private

    def lock_file
      @_lock_file ||= IO.read("Gemfile.lock")
    end
  end
end

module RubyVersions
  class << self
    def lowest_supported
      "#{lowest_supported_minor}.0"
    end

    def lowest_supported_minor
      latest_supported_patches.first[/\d+\.\d+/]
    end

    def latest
      latest_supported_patches.last
    end

    def latest_supported_patches
      patches = [versions[:stable], versions[:security_maintenance]].flatten
      patches.map(&Gem::Version.method(:new)).sort.map(&:to_s)
    end

    private

    def versions
      @_versions ||= begin
        yaml = open(
          "https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/downloads.yml"
        )
        YAML.safe_load(yaml, symbolize_names: true)
      end
    end
  end
end
