# asdf-opengrep

[opengrep](https://github.com/opengrep/opengrep) plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Requirements
- [bash v5.0](https://www.gnu.org/software/bash/)
- [curl](https://curl.haxx.se/)

## Install

```
asdf plugin add opengrep https://github.com/hueys/asdf-opengrep.git
```

## Use

Check [asdf](https://asdf-vm.github.io/asdf/) for instructions on how to install & manage versions of opengrep.

## Install

List opengrep versions:

```
asdf list all opengrep
```

Install a candidate listed from the previous command like this:

```
asdf install opengrep 1.8.2
```

### Setting a version

Select an installed candidate for use like this:

```
asdf set -u opengrep 1.8.2
```
or just for the local directory
```
asdf set opengrep 1.8.2
```
