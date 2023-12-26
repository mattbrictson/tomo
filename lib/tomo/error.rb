module Tomo
  class Error < StandardError
    autoload :Suggestions, "tomo/error/suggestions"

    include Colors

    def self.raise_with(message=nil, attributes)
      err = new(message)
      attributes.each { |attr, value| err.public_send(:"#{attr}=", value) }
      raise err
    end

    private

    def debug_suggestion
      return if Tomo.debug?

      "For more troubleshooting info, run tomo again using the #{blue('--debug')} option."
    end
  end
end
