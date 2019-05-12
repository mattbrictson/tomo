$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tomo/testing"

Tomo::Colors.disable

require "minitest/autorun"
require "minitest/hooks/test"
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |rb| require(rb) }
