module Jam
  class Error < StandardError
    include Jam::Colors

    def self.raise_with(message=nil, attributes)
      err = new(message)
      attributes.each { |attr, value| err.public_send("#{attr}=", value) }
      raise err
    end
  end
end
