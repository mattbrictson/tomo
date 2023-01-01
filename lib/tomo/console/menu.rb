require "forwardable"
require "io/console"

module Tomo
  class Console
    class Menu
      ARROW_UP = "\e[A".freeze
      ARROW_DOWN = "\e[B".freeze
      RETURN = "\r".freeze
      ENTER = "\n".freeze

      extend Forwardable
      include Colors

      def initialize(question, options, key_reader: KeyReader.new, output: $stdout)
        @question = question
        @options = options
        @position = 0
        @key_reader = key_reader
        @output = output
      end

      def selected_option
        options[position]
      end

      def prompt_for_selection
        render_loop do |key|
          case key
          when RETURN, ENTER then break
          when ARROW_UP then move(-1)
          when ARROW_DOWN then move(1)
          else self.position = find_match_index(key)
          end
        end
        print "#{yellow(question)} #{blue(selected_option)}\n"
        selected_option
      end

      private

      def_delegators :@output, :flush, :print

      attr_reader :key_reader, :question, :options
      attr_accessor :position

      def render_loop
        loop do
          render
          key = key_reader.next
          clear
          yield key
        end
      end

      def move(amount)
        new_position = position + amount
        return if new_position.negative? || new_position >= options.length

        self.position = new_position
      end

      def find_match_index(string)
        exact = options.find_index do |opt|
          opt.match?(/^#{Regexp.quote(string)}/i)
        end
        substring = options.find_index do |opt|
          opt.match?(/#{Regexp.quote(string)}/i)
        end

        exact || substring || position
      end

      def render
        print "#{yellow(question)} #{gray(hint)}\n"
        visible_options.each do |option, selected|
          print selected ? blue("❯ #{option}\n") : "  #{option}\n"
        end
        flush
      end

      def hint
        return unless options.length > visible_options.length

        "(press up/down to reveal more options)"
      end

      def clear
        height = visible_options.length + 2
        esc_codes = Array.new(height) { "\e[2K\e[1G" }.join("\e[1A")
        print esc_codes
      end

      def visible_options
        options.map.with_index { |opt, i| [opt, i == position] }[visible_range]
      end

      def visible_range
        max_visible = [8, options.length].min

        offset = [0, position - (max_visible / 2)].max
        adjusted_offset = [offset, options.length - max_visible].min

        adjusted_offset...(adjusted_offset + max_visible)
      end
    end
  end
end
