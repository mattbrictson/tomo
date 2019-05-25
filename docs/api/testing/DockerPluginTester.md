# Tomo::Testing::DockerPluginTester

Similar to [MockPluginTester](MockPluginTester.md), DockerPluginTester is a helper object that allows tasks and helpers provided by plugins to be easily tested. A real SSH connection is used and no mocking is performed. Instead, DockerPluginTester builds a Docker image containing a real SSH server and runs it, sending all remote SSH scripts to that Docker container. This allows for true end-to-end testing.

The Docker image is based on Ubuntu 18.04. The first time DockerPluginTester is used, the base image will be downloaded and a tomo-specific image will be created, which can take a few minutes. Because of the overhead involved, Docker-based tests should be used sparingly and only when they provide high value over much faster unit tests.

Note that you must `require "tomo/testing"` to use DockerPluginTester.

## Class methods

### new(\*plugin_names, settings: {}) → new_tester

Build a new DockerPluginTester that loads the given list of `plugin_names`. The resulting tester object can be used to execute any tasks or helpers that are provided by these plugins. Note that the "core" plugin is always loaded implicitly and does not need to be specified.

Creating a new DockerPluginTester will implicitly build and run a Docker image containing an SSH server. This can take a few minutes the first time the image is built.

Make sure to call [teardown](#teardown) after you are done using the tester.

## Instance methods

### run_task(task, \*args) → nil

Run the given `task` by its fully qualified name (the namespace is required). Any `args`, if specified, are passed to the task via `settings[:run_args]`. Any remote SSH scripts run by the task will be executed via an SSH connection to the Docker container.

### call_helper(helper, \*args, \*\*kwargs) → obj

Invoke the specified `helper` method name with the optional positional `args` and keyword `kwargs`. Returns the return value of the helper. Any remote SSH scripts run by the task will be executed via an SSH connection to the Docker container.

### teardown → nil

Stop the underlying Docker container associated with this tester. Be sure to call `teardown` after the test(s) that use the tester are finished.

### stdout → String

Everything that was written to stdout during the most recent invocation of [run_task][] or [call_helper][]. If nothing was written, then the empty string is returned.

### stderr → String

Everything that was written to stderr during the most recent invocation of [run_task][] or [call_helper][]. If nothing was written, then the empty string is returned.

[call_helper]: #call_helperhelper-42args-4242kwargs-obj
[run_task]: #run_tasktask-42args-nil
