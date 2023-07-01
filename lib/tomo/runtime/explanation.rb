module Tomo
  class Runtime
    class Explanation
      def initialize(applicable_hosts, plan, concurrency)
        @applicable_hosts = applicable_hosts
        @plan = plan
        @concurrency = concurrency
      end

      def to_s # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
              indent.sub!("=", "   ")
            end
            desc << step.explain.gsub(/^/, indent)
          end
        end
        desc.join("\n")
      end

      private

      attr_reader :applicable_hosts, :plan, :concurrency
    end
  end
end
