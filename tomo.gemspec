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
    "homepage_uri" => "https://github.com/mattbrictson/tomo",
    "source_code_uri" => "https://github.com/mattbrictson/tomo"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "concurrent-ruby", "~> 1.1"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "mocha", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", "0.67.2"
  spec.add_development_dependency "rubocop-performance", "1.0.0"
end
