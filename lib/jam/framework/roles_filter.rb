module Jam
  class Framework
    class RolesFilter
      def initialize(roles_spec)
        @spec = (roles_spec || { "*" => "*" }).freeze
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
        roles_spec.each_with_object({}) do |(role_spec, project_specs), globs|
          role_glob = Glob.new(role_spec)
          project_globs = Array(project_specs).map { |spec| Glob.new(spec) }

          globs[role_glob] = project_globs
        end
      end

      def match?(task, role)
        role_globs = globs.keys.select { |glob| glob.match?(role) }
        return false if role_globs.empty?

        role_globs.any? do |key|
          project_globs = globs[key]
          project_globs.any? { |glob| glob.match?(task) }
        end
      end
    end
  end
end
