lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tomo/version"

Gem::Specification.new do |spec|
  spec.name          = "tomo"
  spec.version       = Tomo::VERSION
  spec.authors       = ["Matt Brictson"]
  spec.email         = ["opensource@mattbrictson.com"]

  spec.summary       = "A simple SSH-based deployment tool, built for Rails"
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

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "concurrent-ruby", "~> 1.1"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-ci", "~> 3.4"
  spec.add_development_dependency "minitest-hooks", "~> 1.5"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "0.75.0"
  spec.add_development_dependency "rubocop-minitest", "0.3.0"
  spec.add_development_dependency "rubocop-performance", "1.5.0"
end
