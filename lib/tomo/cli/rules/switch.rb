class Tomo::CLI::Rules
  class Switch
    def initialize(key, *switches, callback_proc:, required: false, &convert_proc)
      @key = key
      @switches = switches
      @callback_proc = callback_proc
      @convert_proc = convert_proc || proc { true }
      @required = required
    end

    def match(arg, literal: false)
      return nil if literal

      1 if switches.include?(arg)
    end

    def process(arg, state:)
      value = convert_proc.call(arg)
      callback_proc&.call(value)
      state.parsed_option(key, value)
    end

    def candidates(literal: false, **_kwargs)
      literal ? [] : switches
    end

    def required?
      @required
    end

    def multiple?
      true
    end

    private

    attr_reader :key, :switches, :convert_proc, :callback_proc
  end
end
