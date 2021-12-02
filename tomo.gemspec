require_relative "lib/tomo/version"

Gem::Specification.new do |spec|
  spec.name = "tomo"
  spec.version = Tomo::VERSION
  spec.authors = ["Matt Brictson"]
  spec.email = ["opensource@mattbrictson.com"]

  spec.summary = "A friendly CLI for deploying Rails apps ✨"
  spec.description = \
    "Tomo is a feature-rich deployment tool that contains everything you need to deploy a basic Rails app out of the "\
    "box. It has an opinionated, production-tested set of defaults, but is easily extensible via a well-documented "\
    "plugin system. Unlike other Ruby-based deployment tools, tomo’s friendly command-line interface and task system "\
    "do not rely on Rake."

  spec.homepage = "https://github.com/mattbrictson/tomo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/tomo/issues",
    "changelog_uri" => "https://github.com/mattbrictson/tomo/releases",
    "source_code_uri" => "https://github.com/mattbrictson/tomo",
    "homepage_uri" => spec.homepage,
    "documentation_uri" => "https://tomo-deploy.com/",
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
