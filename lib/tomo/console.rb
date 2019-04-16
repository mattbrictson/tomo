require "io/console"

module Tomo
  module Console
    autoload :KeyReader, "tomo/console/key_reader"
    autoload :Menu, "tomo/console/menu"

    class << self
      def interactive?(input=$stdin)
        input.respond_to?(:raw) && input.respond_to?(:tty?) && input.tty?
      end

      def prompt(question)
        assert_interactive

        print question
        $stdin.gets.chomp
      end

      def menu(question, choices:)
        assert_interactive

        Menu.new(question, choices).prompt_for_selection
      end

      private

      def assert_interactive
        raise "An interactive console is required" unless interactive?
      end
    end
  end
end
