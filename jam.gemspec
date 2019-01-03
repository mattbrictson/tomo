lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jam/version"

Gem::Specification.new do |spec|
  spec.name          = "jam"
  spec.version       = Jam::VERSION
  spec.authors       = ["Matt Brictson"]
  spec.email         = ["opensource@mattbrictson.com"]

  spec.summary       = "A simple SSH-based deployment tool, built for Rails"
  spec.homepage      = "https://github.com/mattbrictson/jam"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "concurrent-ruby", "~> 1.1"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "minitest-reporters", "~> 1.3"
  spec.add_development_dependency "mocha", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", "0.62.0"
end
