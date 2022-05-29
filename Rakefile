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

# == "rake release" enhancements ==============================================

Rake::Task["release"].enhance do
  puts "Don't forget to publish the release on GitHub!"
  system "open https://github.com/mattbrictson/tomo/releases"
end

task :disable_overcommit do
  ENV["OVERCOMMIT_DISABLE"] = "1"
end

Rake::Task[:build].enhance [:disable_overcommit]

task :verify_gemspec_files do
  git_files = `git ls-files -z`.split("\x0")
  gemspec_files = Gem::Specification.load("tomo.gemspec").files.sort
  ignored_by_git = gemspec_files - git_files
  next if ignored_by_git.empty?

  raise <<~ERROR

    The `spec.files` specified in tomo.gemspec include the following files
    that are being ignored by git. Did you forget to add them to the repo? If
    not, you may need to delete these files or modify the gemspec to ensure
    that they are not included in the gem by mistake:

    #{ignored_by_git.join("\n").gsub(/^/, '  ')}

  ERROR
end

Rake::Task[:build].enhance [:verify_gemspec_files]

# == "rake bump" tasks ========================================================

task bump: %w[bump:bundler bump:ruby bump:year]

namespace :bump do
  task :bundler do
    version = Gem.latest_version_for("bundler").to_s
    replace_in_file ".circleci/config.yml", /bundler -v (\S+)/ => version
    replace_in_file "Gemfile.lock", /^BUNDLED WITH\n\s+(\d\S+)$/ => version
  end

  task :ruby do
    lowest = RubyVersions.lowest
    latest = RubyVersions.latest
    all_supported = RubyVersions.all_supported

    replace_in_file "tomo.gemspec", /ruby_version = .*">= (.*)"/ => lowest
    replace_in_file ".rubocop.yml", /TargetRubyVersion: (.*)/ => lowest
    replace_in_file ".circleci/config.yml", /default: "([\d.]+)"/ => latest
    replace_in_file ".circleci/config.yml", /version: (\[.+\])/ => all_supported.inspect
  end

  task :year do
    replace_in_file "LICENSE.txt", /\(c\) (\d+)/ => Date.today.year.to_s
  end
end

require "date"
require "open-uri"
require "yaml"

def replace_in_file(path, replacements)
  contents = File.read(path)
  orig_contents = contents.dup
  replacements.each do |regexp, text|
    raise "Can't find #{regexp} in #{path}" unless regexp.match?(contents)

    contents.gsub!(regexp) do |match|
      match[regexp, 1] = text
      match
    end
  end
  File.write(path, contents) if contents != orig_contents
end

module RubyVersions
  class << self
    def lowest
      all_supported.first
    end

    def latest
      all_supported.last
    end

    def all_supported
      patches = versions.values_at(:stable, :security_maintenance, :eol).compact.flatten
      patches.map { |p| Gem::Version.new(p[/\d+\.\d+/]) }.sort.map(&:to_s)
    end

    private

    def versions
      @_versions ||= begin
        yaml = URI.open("https://raw.githubusercontent.com/ruby/www.ruby-lang.org/HEAD/_data/downloads.yml")
        YAML.safe_load(yaml, symbolize_names: true)
      end
    end
  end
end
