lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tomo/version"

Gem::Specification.new do |spec|
  spec.name          = "tomo"
  spec.version       = Tomo::VERSION
  spec.authors       = ["Matt Brictson"]
  spec.email         = ["opensource@mattbrictson.com"]

  spec.summary       = "A friendly CLI for deploying Rails apps ✨"
  spec.description   = "Tomo is a feature-rich deployment tool that contains everything you need to deploy a basic "\
                       "Rails app out of the box. It has an opinionated, production-tested set of defaults, but is "\
                       "easily extensible via a well-documented plugin system. Unlike other Ruby-based deployment "\
                       "tools, tomo’s friendly command-line interface and task system do not rely on Rake."
  spec.homepage      = "https://github.com/mattbrictson/tomo"
  spec.license       = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/tomo/issues",
    "changelog_uri" => "https://github.com/mattbrictson/tomo/releases",
    "source_code_uri" => "https://github.com/mattbrictson/tomo",
    "homepage_uri" => "https://tomo-deploy.com/",
    "documentation_uri" => "https://tomo-deploy.com/"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = `git ls-files -z exe lib LICENSE.txt README.md`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "concurrent-ruby", "~> 1.1"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-ci", "~> 3.4"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "0.85.1"
  spec.add_development_dependency "rubocop-minitest", "0.9.0"
  spec.add_development_dependency "rubocop-performance", "1.6.1"
end
