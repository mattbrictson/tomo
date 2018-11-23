# If I run `jam run -e production bundler:clean`, how does jam know which hosts
# to run that task on??? Is the user forced to clarify it by passing something
# like `--tags app`? This seems like a fundamental problem with the decision to
# remove roles from task definitions. At the same time, I don't like how in
# capistrano plugin authors have to define abstractions on top of roles so that
# they can be overridden per project. I suppose jam could search through the
# "deploy" plan, find the bundler:clean task, and get the tags that were
# specified there. But what if the task appears in the plan more than once?
