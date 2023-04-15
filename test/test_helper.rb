$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tomo/testing"

require "minitest/autorun"
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |rb| require(rb) }
