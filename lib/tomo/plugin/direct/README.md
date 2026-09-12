# Direct Plugin

Deploy directly from your local filesystem to the target server via tarball streaming, bypassing the need for a git repository.

## Usage

```ruby
# .tomo/config.rb
plugin "direct"

host "deployer@app.example.com"

set application: "myapp"
set deploy_to: "/var/www/%{application}"
set direct_exclusions: %w[
  .env*
  log
  tmp
  node_modules
]

setup do
  ...
  run "direct:create_release" # instead of git:*
  ...
end

deploy do
  ...
  run "direct:create_release" # instead of git:create_release
  ...
end
```
