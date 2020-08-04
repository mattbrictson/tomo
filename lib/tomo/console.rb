require "forwardable"
require "io/console"

module Tomo
  class Console
    autoload :KeyReader, "tomo/console/key_reader"
    autoload :Menu, "tomo/console/menu"
    autoload :NonInteractiveError, "tomo/console/non_interactive_error"

    class << self
      extend Forwardable
      def_delegators :@instance, :interactive?, :prompt, :menu
    end

    def initialize(env=ENV, input=$stdin, output=$stdout)
      @env = env
      @input = input
      @output = output
    end

    def interactive?
      input.respond_to?(:raw) && input.respond_to?(:tty?) && input.tty? && !ci?
    end

    def prompt(question)
      assert_interactive

      output.print question
      line = input.gets
      raise_non_interactive if line.nil?

      line.chomp
    end

    def menu(question, choices:)
      assert_interactive

      Menu.new(question, choices).prompt_for_selection
    end

    private

    attr_reader :env, :input, :output

    CI_VARS = %w[
      JENKINS_HOME
      JENKINS_URL
      GITHUB_ACTION
      TRAVIS
      CIRCLECI
      TEAMCITY_VERSION
      bamboo_buildKey
      GITLAB_CI
      CI
    ].freeze
    private_constant :CI_VARS

    def ci?
      (env.keys & CI_VARS).any?
    end

    def assert_interactive
      raise_non_interactive unless interactive?
    end

    def raise_non_interactive
      NonInteractiveError.raise_with(task: Runtime::Current.task, ci_var: (env.keys & CI_VARS).first)
    end
  end
end

Tomo::Console.instance_variable_set :@instance, Tomo::Console.new
