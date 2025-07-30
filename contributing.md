# Contributing

Testing Locally:

```shell
asdf plugin test opengrep https://github.com/hueys/asdf-opengrep.git [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test opengrep https://github.com/hueys/asdf-opengrep.git "opengrep --version"
```

Tests are automatically run in GitHub Actions on push and PR.
