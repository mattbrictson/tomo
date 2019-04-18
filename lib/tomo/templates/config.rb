plugin "git"
plugin "env"
plugin "bundler"
plugin "rails"
plugin "rbenv"
plugin "./plugins/%%APP%%.rb"

host "user@hostname.or.ip.address"

set application: "%%APP%%"
set deploy_to: "/var/www/%<application>"
set rbenv_ruby_version: "%%RUBY_VERSION%%"
set git_url: "%%GIT_URL%%"
set git_branch: "master"
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]
set env_vars: {
  RAILS_ENV: "production",
  RACK_ENV: "production",
  SECRET_KEY_BASE: :prompt
}
set linked_dirs: %w[
  .bundle
  public/assets
]

setup do
  run "env:setup"
  run "core:setup_directories"
  run "git:clone"
  run "git:create_release"
  run "core:create_shared_directories"
  run "core:symlink_shared_directories"
  run "rbenv:install"
  run "bundler:upgrade_bundler"
  run "bundler:install"
  run "rails:db_create"
  run "rails:db_schema_load"
  run "rails:db_seed"
end

deploy do
  run "env:update"
  run "git:create_release"
  run "core:symlink_shared_directories"
  run "core:write_release_json"
  run "bundler:install"
  run "rails:assets_precompile"
  run "rails:db_migrate"
  run "core:symlink_current"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
