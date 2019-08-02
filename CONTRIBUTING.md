# Contribution guide

Tomo wouldn't be possible without the generosity of the open source community. Thank you for your input and support! Here are some guidelines to follow when contributing.

## 🐛 Bug reports

- Explain the troubleshooting steps you've already tried
- Use `--debug` and `--trace` to provide additional detail
- Use GitHub-flavored Markdown, especially code fences <code>```</code> to format logs
- Redact any sensitive information
- Include reproduction steps or code for a failing test case if you can

## ✨ Feature requests

Ideas for new tomo features are appreciated!

> The current guiding principle for tomo is to be a "batteries included" tool that encapsulates best practices for deploying Rails apps to inexpensive cloud hosting infrastructure. In considering feature requests, weight will be given to keeping tomo simple to use and simple to maintain, even if that means that certain edge cases and deployment scenarios are unsupported.

- Show examples of how the feature would work
- Explain your motivation for requesting the feature
- Would it be useful for the majority of tomo users?
- Is it a breaking change?

## ⤴️ Pull requests

> Protip: If you have a big change in mind, it is a good idea to open an issue first to propose the idea and get some initial feedback.

### Working on code

- You will need docker to run the full suite of tests (although this is not required)
- Run `bundle install` to install dependencies
- `bin/console` opens an irb console if you need a REPL to try things out
- `bundle exec tomo` will run your working copy of tomo
- `rake install` will install your working copy of tomo globally (so you can test it in other projects)
- Make sure to run `rake` to run all tests and RuboCop checks prior to opening a PR

### Working on docs

- You will need python to build the docs
- Run `pip install -r requirements.txt` to install the relevant python packages
- Start the docs server by running `mkdocs serve`
- Browse the rendered docs at <http://localhost:8000/>

Note that the home page will be blank when running locally. When deployed, the home page will contain the contents of `README.md`.

### PR guidelines

- Give the PR a concise and descriptive title that completes this sentence: _If this PR is merged, it will [TITLE]_
- If the PR fixes an open issue, link to the issue in the description
- Provide a description that ideally answers these questions:
  - Why is this change needed? What problem(s) does it solve?
  - Were there alternative solutions that you considered?
  - How has it been tested?
  - Is it a breaking change?
  - Does the documentation need to be updated?
