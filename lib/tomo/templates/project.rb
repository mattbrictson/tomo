plugin "git"
plugin "bundler"
plugin "rails"

host "user@hostname.or.ip.address"

set application: "%%APP%%"
set deploy_to: "/var/www/%<application>"
set git_branch: "master"
set git_exclusions: %w[
  .tomo/
  spec/
  test/
]
set git_url: "%%GIT_URL%%"
set linked_dirs: %w[
  .bundle
  public/assets
]

deploy do
  run "git:clone"
  run "git:create_release"
  run "core:create_shared_directories"
  run "core:symlink_shared_directories"
  run "core:write_release_json"
  run "bundler:upgrade_bundler"
  run "bundler:install"
  run "rails:assets_precompile"
  run "rails:db_migrate"
  run "rails:db_seed"
  run "core:symlink_current"
  run "core:clean_releases"
  run "bundler:clean"
  run "core:log_revision"
end
