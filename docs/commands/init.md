# init

Start a new tomo project with a sample config.

## Usage

```sh
$ tomo init [APP]
```

Set up a new tomo project named `APP`. If `APP` is not specified, the name of the current directory will be used. This command creates a `.tomo/config.rb` file relative the current directory containing some example configuration. Refer to [Configuration](../configuration.md) for a detailed explanation of this file.

`tomo init` will make educated guesses about your project and fill in some configuration settings for you:

- `nvm_node_version` based on `node --version`
- `nvm_yarn_version` based on `yarn --version`
- `git_url` based on metadata in `.git/` for this project, if present
- `rbenv_ruby_version` based on the version of Ruby being used to run tomo

## Options

| Option | Purpose |
| ------ | ------- |
{!common_options.md.include!}

## Example

```plain
$ cd my-rails-app
$ tomo init
✔ Created .tomo/config.rb
```
