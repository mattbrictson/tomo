# Tomo::Testing::MockPluginTester

MockPluginTester is a helper object that allows tasks and helpers provided by plugins to be easily unit tested. It has no test framework dependencies so it can be used in Minitest, RSpec, or the testing framework of your choice.

MockPluginTester works by mocking the underlying SSH connection so that no actual remote SSH scripts are run. By default, the tester will simulate that the script runs successfully (exit status of 0) with empty stdout and stderr. You can then write assertions verifying that the script was run as expected. For example:

```ruby
require "tomo/testing"

def test_setup_directories
  tester = Tomo::Testing::MockPluginTester.new(settings: { deploy_to: "/app" })
  tester.run_task("core:setup_directories")
  assert_equal("mkdir -p /app /app/releases /app/shared", tester.executed_script)
end
```

You can change the default mocking behavior by using [mock_script_result][], like this:

```ruby
require "tomo/testing"

def test_install
  tester = Tomo::Testing::MockPluginTester.new(
    "bundler", settings: { release_path: "/app/release" }
  )
  tester.mock_script_result(/bundle check/, exit_status: 1)
  tester.run_task("bundler:install")
  assert_equal(
    [
      "cd /app/release && bundle check",
      "cd /app/release && bundle install"
    ],
    tester.executed_scripts
  )
end
```

Every MockPluginTester instance loads a fresh, independent tomo environment, so mocks, plugins, settings, etc. specified in one tester will not affect any other tests.

Note that you must `require "tomo/testing"` to use MockPluginTester.

## Class methods

### new(\*plugin_names, settings: {}, release: {}) → new_tester

Build a new MockPluginTester that loads the given list of `plugin_names`. The resulting tester object can be used to simulate any tasks or helpers that are provided by these plugins. Note that the "core" plugin is always loaded implicitly and does not need to be specified.

Any `settings` that are specified will be applied _after_ the defaults settings provided by the plugins have been defined. These settings can use template strings just like [set](../../configuration.md#sethash).

```ruby
require "tomo/testing"

tester = Tomo::Testing::MockPluginTester.new(
  "puma",
  settings: {
    application: "test",
    current_path: "/app/current"
  }
)
```

Any `release` data specified will be available to the task under test via `remote.release`.

## Instance methods

### run_task(task, \*args) → nil

Run the given `task` by its fully qualified name (the namespace is required). Any `args`, if specified, are passed to the task via `settings[:run_args]`.

Any remote SSH scripts run by the task (e.g. via `remote.run`) will be mocked according to rules previously supplied to [mock_script_result][]. If a mock result has not been explicitly supplied, the script will use a default mock that returns a successful result with no output.

```ruby
require "tomo/testing"

tester = Tomo::Testing::MockPluginTester.new(
  "bundler", settings: { release_path: "/app/release" }
)
tester.mock_script_result(/bundle check/, exit_status: 1)
tester.run_task("bundler:install")
assert_equal(
  [
    "cd /app/release && bundle check",
    "cd /app/release && bundle install"
  ],
  tester.executed_scripts
)
```

### call_helper(helper, \*args, \*\*kwargs) → obj

Invoke the specified `helper` method name with the optional positional `args` and keyword `kwargs`. Returns the return value of the helper. Remote SSH scripts are mocked as explained in [run_task][].

```ruby
require "tomo/testing"

def test_capture_returns_stdout_not_stderr
  tester = Tomo::Testing::MockPluginTester.new
  tester.mock_script_result(stderr: "oh no", stdout: "hello world\n")
  captured = tester.call_helper(:capture, "greet")
  assert_equal("hello world\n", captured)
end
```

### mock_script_result(script=/.\*/, stdout: "", stderr: "", exit_status: 0) → self

Mock the return value of remote SSH scripts that match the given `script`. If `script` is a String, the mock rule will apply only to scripts that match this String exactly. If `script` is Regexp, the mock rule will apply to any scripts that match that pattern. If `script` is omitted, the mock rule will apply always.

In this example, any task or helper invoked via this tester that runs `readline /app/current` will receive the given mock stdout response:

```ruby
tester.mock_script_result("readlink /app/current", stdout: <<~OUT)
  /app/releases/20190420203028
OUT
```

Here, any script that includes `systemctl` will fail with an exit status of 1:

```ruby
tester.mock_script_result(/systemctl/, exit_status: 1)
```

This mocks _all_ scripts to fail with exit status of 255 and stderr of "oh no!":

```ruby
tester.mock_script_result(exit_status: 255, stderr: "oh no!")
```

### executed_script → String

The remote SSH script that was run by a previous invocation of [run_task][] or [call_helper][]. If no script was run, then `nil` is returned. If more that one script was run, this will raise a `RuntimeError`.

### executed_scripts → [String]

All remote SSH scripts that were run by a previous invocation of [run_task][] or [call_helper][]. If no script was run, then an empty array is returned.

### stdout → String

Everything that was written to stdout during the most recent invocation of [run_task][] or [call_helper][]. If nothing was written, then the empty string is returned.

### stderr → String

Everything that was written to stderr during the most recent invocation of [run_task][] or [call_helper][]. If nothing was written, then the empty string is returned.

[call_helper]: #call_helperhelper-42args-4242kwargs-obj
[mock_script_result]: #mock_script_resultscript42-stdout-stderr-exit_status-0-self
[run_task]: #run_tasktask-42args-nil
