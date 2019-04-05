module Tomo
  module Utils
    module_function

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), symbolized|
        symbolized[key.to_sym] = value
      end
    end
  end
end
