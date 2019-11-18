module Tomo
  class Runtime
    class Explanation
      def initialize(applicable_hosts, plan, concurrency)
        @applicable_hosts = applicable_hosts
        @plan = plan
        @concurrency = concurrency
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      def to_s
        desc = []
        threads = [applicable_hosts.length, concurrency].min
        desc << "CONCURRENTLY (#{threads} THREADS):" if threads > 1
        applicable_hosts.each do |host|
          indent = threads > 1 ? "  = " : ""
          desc << "#{indent}CONNECT #{host}"
        end
        plan.each do |steps|
          threads = [steps.length, concurrency].min
          desc << "CONCURRENTLY (#{threads} THREADS):" if threads > 1
          steps.each do |step|
            indent = threads > 1 ? "  = " : ""
            if threads > 1 && step.applicable_tasks.length > 1
              desc << "#{indent}IN SEQUENCE:"
              indent.sub!(/=/, "   ")
            end
            desc << step.explain.gsub(/^/, indent)
          end
        end
        desc.join("\n")
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      attr_reader :applicable_hosts, :plan, :concurrency
    end
  end
end
