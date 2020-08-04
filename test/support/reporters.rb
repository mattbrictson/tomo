require "minitest/reporters"

if ENV["CI"]
  Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
else
  Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)
end
