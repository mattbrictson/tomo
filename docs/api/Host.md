# Tomo::Host

Represents a remote SSH host.

```ruby
host.address # => "example.com"
host.port    # => 22
host.user    # => "deployer"
host.roles   # => ["app", "db"]
host.to_s    # => "deployer@example.com"
```

A Host is always frozen and cannot be modified.

## Instance methods

### address → String

The host name or IP address.

### port → Integer

The SSH port, usually 22.

### user → String

The username used when connecting to the host via SSH.

### roles → [String]

An array of roles that are assigned to this host. Roles are used in multi-host deployments to control which tasks are run on which hosts.

### to_s → String

A representation of host in the form of `user@address:port`. If the port is 22, that portion is omitted.
