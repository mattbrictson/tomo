module Tomo
  class CLI
    class Rules
      autoload :Argument, "tomo/cli/rules/argument"
      autoload :Switch, "tomo/cli/rules/switch"
      autoload :ValueSwitch, "tomo/cli/rules/value_switch"

      ARG_PATTERNS = {
        /\A\[[A-Z_]+\]\z/       => :optional_arg_rule,
        /\A[A-Z_]+\z/           => :required_arg_rule,
        /\A\[[A-Z_]+\.\.\.\]\z/ => :mutiple_optional_args_rule
      }.freeze

      OPTION_PATTERNS = {
        /\A--\[no-\]([-a-z]+)\z/              => :on_off_switch_rule,
        /\A(-[a-z]), (--[-a-z]+)\z/           => :basic_switch_rule,
        /\A(-[a-z]), (--[-a-z]+) [A-Z=_-]+\z/ => :value_switch_rule
      }.freeze

      private_constant :ARG_PATTERNS, :OPTION_PATTERNS

      def initialize
        @rules = []
      end

      def add_arg(spec, values_proc)
        rule = ARG_PATTERNS.find do |regexp, method|
          break send(method, spec, values_proc) if regexp.match?(spec)
        end
        raise ArgumentError, "Unrecognized arg style: #{spec}" if rule.nil?

        rules << rule
      end

      def add_option(key, spec, values_proc, &block)
        rule = OPTION_PATTERNS.find do |regexp, method|
          match = regexp.match(spec)
          break send(method, key, *match.captures, values_proc, block) if match
        end
        raise ArgumentError, "Unrecognized option style: #{spec}" if rule.nil?

        rules << rule
      end

      def to_a
        rules
      end

      private

      attr_reader :rules

      def optional_arg_rule(spec, values_proc)
        Rules::Argument.new(spec, values_proc: values_proc, required: false, multiple: false)
      end

      def required_arg_rule(spec, values_proc)
        Rules::Argument.new(spec, values_proc: values_proc, required: true, multiple: false)
      end

      def mutiple_optional_args_rule(spec, values_proc)
        Rules::Argument.new(spec, multiple: true, values_proc: values_proc)
      end

      def on_off_switch_rule(key, name, _values_proc, callback_proc)
        Rules::Switch.new(key, "--#{name}", "--no-#{name}", callback_proc: callback_proc) do |arg|
          arg == "--#{name}"
        end
      end

      def basic_switch_rule(key, *switches, _values_proc, callback_proc)
        Rules::Switch.new(key, *switches, callback_proc: callback_proc)
      end

      def value_switch_rule(key, *switches, values_proc, callback_proc)
        Rules::ValueSwitch.new(key, *switches, values_proc: values_proc, callback_proc: callback_proc)
      end
    end
  end
end
