class Tomo::CLI::Rules
  class Argument
    def initialize(label, multiple: false, required: false, values_proc:)
      @label = label
      @multiple = multiple
      @required = required
      @values_proc = values_proc
    end

    def match(arg, literal: false)
      1 if literal || !arg.start_with?("-")
    end

    def process(arg, state:)
      state.parsed_arg(arg)
    end

    def candidates(literal: false, state:)
      values(state).reject { |val| literal && val.start_with?("-") }
    end

    def required?
      @required
    end

    def multiple?
      @multiple
    end

    def to_s
      @label
    end

    private

    attr_reader :values_proc

    def values(state)
      values_proc.call(*state.args, state.options)
    end
  end
end
