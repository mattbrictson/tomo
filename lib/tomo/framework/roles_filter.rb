module Tomo
  class Framework
    class RolesFilter
      def initialize(roles_spec)
        @spec = (roles_spec || {}).freeze
        @globs = parse_spec(@spec).freeze
        freeze
      end

      def filter_tasks(tasks, roles: [])
        roles = roles.empty? ? [""] : roles
        tasks.select do |task|
          roles.any? { |role| match?(task, role) }
        end
      end

      def to_s
        spec.inspect
      end

      private

      attr_reader :globs, :spec

      def parse_spec(roles_spec)
        roles_spec.each_with_object({}) do |(role_spec, task_specs), globs|
          role_glob = Glob.new(role_spec)
          task_globs = Array(task_specs).map { |spec| Glob.new(spec) }

          task_globs.each do |task_glob|
            (globs[task_glob] ||= []) << role_glob
          end
        end
      end

      def match?(task, role)
        task_globs = globs.keys.select { |glob| glob.match?(task) }
        return true if task_globs.empty?

        role_globs = globs.values_at(*task_globs).flatten
        role_globs.any? { |glob| glob.match?(role) }
      end
    end
  end
end
