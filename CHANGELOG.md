# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive test suite with GitHub Actions workflows
- Platform detection improvements with better error messages
- GitHub API rate limiting documentation and handling
- Local development test script (`scripts/test.bash`)
- Support for both glibc and musl Linux distributions
- Troubleshooting section in README
- Changelog for tracking project changes

### Changed
- Improved README with better usage examples and current version numbers
- Enhanced error handling in `latest-stable` script
- Better version sorting algorithm for semver compatibility
- More robust platform detection and architecture normalization
- Pinned GitHub Actions to specific commit hashes for security

### Fixed
- Removed debug output from `latest-stable` script
- Fixed installation verification to test binary functionality
- Improved download URL construction and error reporting

### Removed
- Unused `version.txt` file

## [0.1.0] - TBD

### Added
- Initial plugin implementation
- Support for Linux (x86_64, aarch64) and macOS (Intel, Apple Silicon)
- Basic ASDF plugin structure with required scripts
- GitHub Actions for linting and release automation
- shellcheck and shfmt integration
- Basic documentation

[unreleased]: https://github.com/hueys/asdf-opengrep/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/hueys/asdf-opengrep/releases/tag/v0.1.0