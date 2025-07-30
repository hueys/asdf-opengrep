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

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
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

	# check and set "os_arch"
    if [ "$OS" = "Linux" ]; then
        if ldd /bin/sh 2>&1 | grep -qi musl; then
            if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
                DIST="opengrep_musllinux_x86"
            elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                DIST="opengrep_musllinux_aarch64"
            fi
        else
            if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
                DIST="opengrep_manylinux_x86"
            elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                DIST="opengrep_manylinux_aarch64"
            fi
        fi
    elif [ "$OS" = "Darwin" ]; then
        if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
            DIST="opengrep_osx_x86"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            DIST="opengrep_osx_arm64"
        fi
    fi

    if [ -z "${DIST}" ]; then
        echo "Operating system '${OS}' / architecture '${ARCH}' is unsupported." 1>&2
        exit 1
    fi

    url="https://github.com/opengrep/opengrep/releases/download/${VERSION}/${DIST}"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
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
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# Assert opengrep executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
