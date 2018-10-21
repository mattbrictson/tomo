$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jam"

require "minitest/autorun"
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |rb| require(rb) }
