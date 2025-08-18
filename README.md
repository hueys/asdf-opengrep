# asdf-opengrep

[opengrep](https://github.com/opengrep/opengrep) plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Requirements
- [bash v5.0](https://www.gnu.org/software/bash/)
- [curl](https://curl.haxx.se/)

## GitHub API Rate Limiting

This plugin uses the GitHub API to fetch version information. To avoid rate limiting issues, you can set a GitHub personal access token:

```bash
export GITHUB_API_TOKEN="your_github_token_here"
```

You can create a token at [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens). No special scopes are required for public repositories.

## Install

```bash
asdf plugin add opengrep https://github.com/hueys/asdf-opengrep.git
```

## Use

Check [asdf](https://asdf-vm.github.io/asdf/) for instructions on how to install & manage versions of opengrep.

## Usage

List available opengrep versions:

```bash
asdf list all opengrep
```

Install a specific version:

```bash
asdf install opengrep 1.8.3
```

Set global version:

```bash
asdf global opengrep 1.8.3
```

Set local version for current directory:

```bash
asdf local opengrep 1.8.3
```

Verify installation:

```bash
opengrep --version
```

## Troubleshooting

### Rate Limiting
If you encounter rate limiting errors when listing or installing versions, set the `GITHUB_API_TOKEN` environment variable as described above.

### Platform Support
This plugin supports:
- Linux x86_64 (glibc and musl)
- Linux aarch64 (glibc and musl) 
- macOS x86_64 (Intel)
- macOS aarch64 (Apple Silicon)

### Installation Issues
If installation fails, check:
1. Your platform is supported (see above)
2. The version exists in [opengrep releases](https://github.com/opengrep/opengrep/releases)
3. Your internet connection allows downloading from GitHub
