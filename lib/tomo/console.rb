require "forwardable"
require "io/console"

module Tomo
  class Console
    autoload :KeyReader, "tomo/console/key_reader"
    autoload :Menu, "tomo/console/menu"

    class << self
      extend Forwardable
      def_delegators :@instance, :interactive?, :prompt, :menu
    end

    def initialize(env=ENV, input=$stdin)
      @env = env
      @input = input
    end

    def interactive?
      input.respond_to?(:raw) &&
        input.respond_to?(:tty?) &&
        input.tty? &&
        !ci?
    end

    def prompt(question)
      assert_interactive

      print question
      line = input.gets
      raise_non_interactive if line.nil?

      line.chomp
    end

    def menu(question, choices:)
      assert_interactive

      Menu.new(question, choices).prompt_for_selection
    end

    private

    attr_reader :env, :input

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
      raise "An interactive console is required" unless ci?

      env_var = (env.keys & CI_VARS).first
      raise <<~ERROR
        This appears to be a CI environment because the #{env_var} env var is set.
        Tomo::Console cannot be used in a non-interactive CI environment.
      ERROR
    end
  end
end

Tomo::Console.instance_variable_set :@instance, Tomo::Console.new
