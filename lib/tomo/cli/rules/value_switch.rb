class Tomo::CLI::Rules
  class ValueSwitch < Switch
    include Tomo::Colors

    def initialize(key, *switches, values_proc:, callback_proc:)
      super(key, *switches, callback_proc: callback_proc)

      @values_proc = values_proc
    end

    def match(arg, literal: false)
      return nil if literal
      return 2 if switches.include?(arg)

      1 if arg.start_with?("--") && switches.include?(arg.split("=").first)
    end

    def process(switch, arg=nil, state:)
      value = if switch.include?("=")
                switch.split("=", 2).last
              elsif !arg.to_s.start_with?("-")
                arg
              end

      raise_missing_value(switch) if value.nil?

      callback_proc&.call(value)
      state.parsed_option(key, value)
    end

    def candidates(switch=nil, state:, literal: false)
      return [] if literal

      vals = values(state)
      return vals.reject { |val| val.start_with?("-") } if switch

      switches.each_with_object([]) do |each_switch, result|
        result << each_switch
        vals.each do |value|
          result << "#{each_switch}=#{value}" if each_switch.start_with?("--")
        end
      end
    end

    private

    attr_reader :values_proc

    def values(state)
      values_proc.call(*state.args, state.options)
    end

    def raise_missing_value(switch)
      raise Tomo::CLI::Error, "Please specify a value for the #{yellow(switch)} option."
    end
  end
end
