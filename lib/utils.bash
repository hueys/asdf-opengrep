#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/opengrep/opengrep"
TOOL_NAME="opengrep"
TOOL_TEST="opengrep --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

sort_versions() {
	# Better semver sorting that handles pre-release versions correctly
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	# By default we simply list the tag names from GitHub releases.
	# Change this function if opengrep has other means of determining installable versions.
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	OS="${OS:-$(uname -s)}"
	ARCH="${ARCH:-$(uname -m)}"
	DIST=""

	# Normalize architecture names
	case "$ARCH" in
	amd64) ARCH="x86_64" ;;
	arm64) ARCH="aarch64" ;;
	esac

	# check and set "os_arch"
	if [ "$OS" = "Linux" ]; then
		# Check if system uses musl libc
		if command -v ldd >/dev/null 2>&1 && ldd /bin/sh 2>&1 | grep -qi musl; then
			case "$ARCH" in
			x86_64) DIST="opengrep_musllinux_x86" ;;
			aarch64) DIST="opengrep_musllinux_aarch64" ;;
			*) ;;
			esac
		else
			case "$ARCH" in
			x86_64) DIST="opengrep_manylinux_x86" ;;
			aarch64) DIST="opengrep_manylinux_aarch64" ;;
			*) ;;
			esac
		fi
	elif [ "$OS" = "Darwin" ]; then
		case "$ARCH" in
		x86_64) DIST="opengrep_osx_x86" ;;
		aarch64) DIST="opengrep_osx_arm64" ;;
		*) ;;
		esac
	fi

	if [ -z "${DIST}" ]; then
		echo "Error: Unsupported platform ${OS}/${ARCH}" >&2
		echo "Supported platforms:" >&2
		echo "  - Linux x86_64 (glibc/musl)" >&2
		echo "  - Linux aarch64 (glibc/musl)" >&2
		echo "  - macOS x86_64" >&2
		echo "  - macOS aarch64 (Apple Silicon)" >&2
		exit 1
	fi

	url="https://github.com/opengrep/opengrep/releases/download/v${version}/${DIST}"

	echo "* Downloading $TOOL_NAME release $version for ${OS}/${ARCH}..."
	echo "* Download URL: $url"
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url. Please check if version $version exists and supports your platform."
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp "${ASDF_DOWNLOAD_PATH}/opengrep" "${install_path}/opengrep"
		chmod +x "${install_path}/opengrep"

		# Assert opengrep executable exists and works
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		# Test that the binary actually works
		if ! "$install_path/$tool_cmd" --version >/dev/null 2>&1; then
			fail "$tool_cmd binary is not working correctly. This might be due to missing dependencies or architecture mismatch."
		fi

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
