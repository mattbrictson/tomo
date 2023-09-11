module Tomo
  class Configuration
    module DSL
      module ErrorFormatter
        class << self
          def decorate(error, path, lines)
            line_no = find_line_no(path, error.message, *error.backtrace[0..1])
            return error if line_no.nil?

            error.extend(self)
            error.dsl_lines = lines || []
            error.dsl_path = path
            error.error_line_no = line_no
            error
          end

          private

          def find_line_no(path, *lines)
            lines.find do |line|
              line_no = line[/^#{Regexp.quote(path)}:(\d+):/, 1]
              break line_no.to_i if line_no
            end
          end
        end

        include Colors

        attr_accessor :dsl_lines, :dsl_path, :error_line_no

        def to_console
          <<~ERROR
            Configuration syntax error in #{yellow(dsl_path)} at line #{yellow(error_line_no)}.

            #{highlighted_lines}
            #{Colors.red([self.class, message].join(': '))}

            Visit #{Colors.blue('https://tomo.mattbrictson.com/configuration')} for syntax reference.
            #{trace_hint}
          ERROR
        end

        private

        def trace_hint
          return "" if CLI.show_backtrace

          <<~HINT
            You can run this command again with #{Colors.blue('--trace')} for a full backtrace.
          HINT
        end

        def highlighted_lines # rubocop:disable Metrics/AbcSize
          first = [1, error_line_no - 1].max
          last = [dsl_lines.length, error_line_no + 1].min
          width = last.to_s.length

          (first..last).each_with_object("") do |line_no, result|
            line = dsl_lines[line_no - 1]
            line_no_prefix = line_no.to_s.rjust(width)

            result << if line_no == error_line_no
                        yellow("→ #{line_no_prefix}: #{line}")
                      else
                        "  #{line_no_prefix}: #{line}"
                      end
          end
        end
      end
    end
  end
end
