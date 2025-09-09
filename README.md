# asdf-opengrep

Unofficial [opengrep](https://github.com/opengrep/opengrep) plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Install

```bash
asdf plugin add opengrep https://github.com/hueys/asdf-opengrep.git
```

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
asdf set --home opengrep 1.8.3
```

Set local version for current directory:

```bash
asdf set opengrep 1.8.3
```

Verify installation:

```bash
opengrep --version
```
