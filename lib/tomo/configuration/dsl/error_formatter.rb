module Tomo
  class Configuration
    module DSL
      module ErrorFormatter
        def self.decorate(error, path, lines)
          unless error.backtrace[0..1].grep(/^#{Regexp.quote(path)}:/)
            return error
          end

          error.extend(self)
          error.dsl_lines = lines
          error.dsl_path = path
          error
        end

        include Colors

        attr_accessor :dsl_lines, :dsl_path

        def to_console
          <<~ERROR
            Configuration syntax error in #{yellow(dsl_path)} at line #{yellow(error_line_no)}.

            #{highlighted_lines}
            #{Colors.red([self.class, message].join(': '))}

            Visit #{Colors.blue('https://tomo-deploy.com/configuration')} for syntax reference.
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

        def error_line_no
          @_error_line_no ||= begin
            pattern = /^#{Regexp.quote(dsl_path)}:(\d+):/
            backtrace.each do |entry|
              match = pattern.match(entry)
              break match[1].to_i if match
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def highlighted_lines
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
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
