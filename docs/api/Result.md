# Tomo::Result

Represents the result of a remote SSH script.

```ruby
result = remote.run("echo", "hello world")
result.success?    # => true
result.failure?    # => false
result.exit_status # => 0
result.stdout      # => "hello world\n"
result.stderr      # => ""
result.output      # => "hello world\n"
```

A Result is always frozen and cannot be modified.

## Instance methods

### success? → true or false

Whether the remote SSH script executed successfully. An exit status of 0 is considered success.

### failure? → true or false

Whether the remote SSH script failed to execute. An non-zero exit status is considered a failure.

### exit_status → Integer

The exit status returned by the remote SSH script. A status of 0 is considered success.

### stdout → String

All data that was written to stdout by the remote SSH script. Empty string if nothing was written.

### stderr → String

All data that was written to stderr by the remote SSH script. Empty string if nothing was written.

### output → String

All data that was written by the remote SSH script: stdout and stderr combined, in that order. Empty string if nothing was written.
