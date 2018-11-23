jam = Jam::Framework.new
jam.load_project!(environment: :auto)
jam.tasks





jam = Jam::Framework.new
jam.load_project!(
  environment: options[:environment],
  settings: options[:settings].merge(release_path: release_path)
)

plan = jam.build_execution_plan("deploy")
plan.execute


Jam.logger

project = Jam.load_project(
  environment: options[:environment],
  settings: options[:settings].merge(release_path: release_path)
)

project.settings
project.tasks
project.helper_modules
project.paths

project.build_execution_plan("deploy")
project.build_task_execution_plan("bundler:clean")

plan.call

# If I run `jam run -e production bundler:clean`, how does jam know which hosts
# to run that task on??? Is the user forced to clarify it by passing something
# like `--tags app`? This seems like a fundamental problem with the decision to
# remove roles from task definitions. At the same time, I don't like how in
# capistrano plugin authors have to define abstractions on top of roles so that
# they can be overridden per project. I suppose jam could search through the
# "deploy" plan, find the bundler:clean task, and get the tags that were
# specified there. But what if the task appears in the plan more than once?
