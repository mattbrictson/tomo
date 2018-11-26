module Jam
  class Error < StandardError
    include Jam::Colors

    def self.raise_with(message=nil, attributes)
      err = new(message)
      attributes.each { |attr, value| err.public_send("#{attr}=", value) }
      raise err
    end

    private

    def debug_suggestion
      return if Jam::SSH.debug?

      "For more troubleshooting info, run jam again using the "\
      "#{blue('--debug')} option."
    end
  end
end
