# git

The git plugin uses git running on the remote host to fetch the code of the app being deployed. This "remote pull" technique is currently the only deployment method officially supported by tomo. For this to work, the SSH key you use to connect to the remote host via tomo must match the key expected by the git host (e.g. by GitHub).

## Settings

| Name             | Purpose                                                                                                                                                                                                               | Default                                                                               |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `git_branch`     | The branch of the repository to deploy                                                                                                                                                                                | `"master"`                                                                            |
| `git_repo_path`  | Directory on the remote host where a cache of the repository will be stored                                                                                                                                           | `"%<deploy_to>/git_repo"`                                                             |
| `git_exclusions` | An array of paths (similar to gitignore syntax) that will be excluded when the repository is copied into a release; it is recommend you exclude `.tomo/` and other directories not needed in production, like `spec/` | `[]`                                                                                  |
| `git_env`        | Environment variables that will be set when issuing git commands (hash)                                                                                                                                               | `{ GIT_SSH_COMMAND: "ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no" }` |
| `git_ref`        | The commit SHA or tag to deploy (overrides `:git_branch`)                                                                                                                                                             | `nil`                                                                                 |
| `git_url`        | URL of the git repository; always use the SSH form like `git@github.com:username/repo.git` (not HTTPS)                                                                                                                | `nil`                                                                                 |

## Tasks

### git:clone

Performs the initial clone of the git repository. This is necessary before a deploy can be performed. The clone of the repository will be stored in the `git_repo_path`. The `git_url` setting must be specified for this task to work.

`git:clone` is intended for use as a [setup](../commands/setup.md) task.

### git:create_release

Fetches the latest commits from `git_branch` (or `git_ref`) and creates a release by copying the contents of that branch of repository into a new release inside the `releases_path`. Releases are numbered based on the timestamp of when the deploy takes place.

`git:create_release` is intended for use as a [deploy](../commands/deploy.md) task.

## Helpers

These helper methods become available on instances of [Remote](../api/Remote.md) when the git plugin is loaded. They accept the same `options` as [Remote#run](../api/Remote.md#run42command-4242options-tomoresult).

### remote.git(\*args, \*\*options) → [Tomo::Result](../api/Result.md)

Runs `git` with the environment variables specified by the `git_env` setting.

```ruby
remote.git("fetch")
# $ export GIT_SSH_COMMAND=ssh\ -o\ PasswordAuthentication=no\ -o\ StrictHostKeyChecking=no && git fetch
```
