# Publishing a Plugin

In this tutorial we will create tomo plugin that can be shared with the community as a Ruby gem. Here is an overview of the steps involved:

- Start with a [project-based plugin](writing-custom-tasks.md) to prove real-world usage
- Use the [tomo-plugin GitHub template](https://github.com/mattbrictson/tomo-plugin) to package your plugin as a Ruby gem
- Write unit tests for your tasks using [MockPluginTester](../api/testing/MockPluginTester.md)
- Add docs and continuous integration (CI) to help your users and contributors
- Publish to [rubygems.org](https://rubygems.org)

## What makes for a good plugin?

## Create the gem

While it is easy to get started writing tasks with a project-based plugin, this ad-hoc style does not have test coverage and is not packaged in a way that makes it easy to share with other projects and the larger tomo community. This is why it is useful to package your plugin in its own Ruby gem project.

### Choose a name

Before packaging your plugin, choose a name. Your gem will be named `tomo-plugin-NAME` where `NAME` is the name of your plugin. Decide on a plugin name that is concise and whose gem name is not already taken at [rubygems.org](https://rubygems.org). For example the "rollbar" plugin corresponds to the [tomo-plugin-rollbar](https://rubygems.org/gems/tomo-plugin-rollbar) gem at rubygems.org.

### Use the tomo-plugin template

Tomo provides a GitHub template that does most of the work of setting up the gem project.

1. Navigate to the [tomo-plugin](https://github.com/mattbrictson/tomo-plugin) template on GitHub
2. Press [Use this template](https://github.com/mattbrictson/tomo-plugin/generate)
3. Name the repo `tomo-plugin-NAME` where `NAME` is the name of the plugin

![GitHub: Create a new repository from tomo-plugin](./create-new-repo@2x.png)

For this example we will use "cron" as the plugin name.

### Run the rename_template.rb script

Use git to clone the resulting GitHub repo. Inside the repo, run:

```plain
$ ruby rename_template.rb
```

This will prompt for some information needed to set up the project. Press enter to accept the default values, which should be sufficient for each question.

```
[example of rename_template.rb script output for cron]
```

Don't forget to `git commit` and `git push` the changes.

## Gem structure

