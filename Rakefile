require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

task default: %i[test rubocop]
desc "Run all tests"
task test: %w[test:unit]

RuboCop::RakeTask.new

Rake::TestTask.new("test:unit") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"] - FileList["test/**/*_e2e_test.rb"]
end

Rake::TestTask.new("test:e2e") do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_e2e_test.rb"]
end

task bump: %w[bump:bundler bump:ruby bump:year]

Rake::Task["release"].enhance do
  puts "Don't forget publish the release on GitHub!"
  system "open https://github.com/mattbrictson/tomo/releases"
end

namespace :bump do
  task :bundler do
    version = Gem.latest_version_for("bundler").to_s
    replace_in_file ".travis.yml", /bundler -v (\S+)/ => version
    replace_in_file ".circleci/config.yml", /bundler -v (\S+)/ => version
    replace_in_file ".circleci/Dockerfile", /bundler -v (\S+)/ => version
    replace_in_file "Gemfile.lock", /^BUNDLED WITH\n\s+([\d.]+)$/ => version
  end

  task :ruby do
    lowest = RubyVersions.lowest_supported
    lowest_minor = RubyVersions.lowest_supported_minor
    latest = RubyVersions.latest
    latest_patches = RubyVersions.latest_supported_patches

    replace_in_file "tomo.gemspec", /ruby_version = .*">= (.*)"/ => lowest
    replace_in_file ".rubocop.yml", /TargetRubyVersion: (.*)/ => lowest_minor
    replace_in_file ".circleci/config.yml", /default: "([\d.]+)"/ => latest
    replace_in_file ".circleci/config.yml", /version: (\[.+\])/ => latest_patches.inspect
    replace_in_file ".circleci/Dockerfile", %r{circleci/ruby:([\d.]+)} => latest
    replace_in_file "docs/comparisons.md", /ruby version\s*\|\s*([\d.]+)/i => lowest_minor
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
    raise "Can't find #{regexp} in #{path}" unless regexp.match?(contents)

    contents.gsub!(regexp) do |match|
      match[regexp, 1] = text
      match
    end
  end
  IO.write(path, contents) if contents != orig_contents
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
        yaml = URI.open("https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/downloads.yml")
        YAML.safe_load(yaml, symbolize_names: true)
      end
    end
  end
end
