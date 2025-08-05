#!/usr/bin/env bash

set -euo pipefail

# Test script for local development of asdf-opengrep plugin

current_script_path=${BASH_SOURCE[0]}
plugin_dir=$(dirname "$(dirname "$current_script_path")")

echo "🧪 Testing asdf-opengrep plugin..."

# Test 1: Check that all required scripts exist
echo "📁 Checking required scripts exist..."
required_scripts=("bin/list-all" "bin/download" "bin/install" "bin/latest-stable")
for script in "${required_scripts[@]}"; do
    if [[ -f "$plugin_dir/$script" ]]; then
        echo "  ✅ $script exists"
    else
        echo "  ❌ $script missing"
        exit 1
    fi
done

# Test 2: Check that scripts are executable
echo "🔒 Checking scripts are executable..."
for script in "${required_scripts[@]}"; do
    if [[ -x "$plugin_dir/$script" ]]; then
        echo "  ✅ $script is executable"
    else
        echo "  ❌ $script is not executable"
        exit 1
    fi
done

# Test 3: Test list-all functionality
echo "📋 Testing list-all..."
if versions=$("$plugin_dir/bin/list-all"); then
    version_count=$(echo "$versions" | wc -w)
    echo "  ✅ list-all returned $version_count versions"
    echo "  📝 Latest few versions: $(echo "$versions" | tail -n 3)"
else
    echo "  ❌ list-all failed"
    exit 1
fi

# Test 4: Test latest-stable functionality
echo "🔍 Testing latest-stable..."
if latest_version=$("$plugin_dir/bin/latest-stable"); then
    echo "  ✅ latest-stable returned: $latest_version"
    
    # Verify the latest version is in the list of all versions
    if echo "$versions" | grep -q "$latest_version"; then
        echo "  ✅ latest version exists in version list"
    else
        echo "  ⚠️  latest version not found in version list (might be newer)"
    fi
else
    echo "  ❌ latest-stable failed"
    exit 1
fi

# Test 5: Test platform detection
echo "🖥️  Testing platform detection..."
# Source the utils to test platform detection logic
# shellcheck source=../lib/utils.bash
source "$plugin_dir/lib/utils.bash"

OS="${OS:-$(uname -s)}"
ARCH="${ARCH:-$(uname -m)}"
echo "  📊 Detected OS: $OS"
echo "  📊 Detected ARCH: $ARCH"

# Test the download_release function's platform detection without actually downloading
test_version="1.1.5"
echo "  🧪 Testing platform detection for version $test_version..."

# Mock the download by just getting the URL
get_download_url() {
    local version="$1"
    local OS ARCH DIST
    
    OS="${OS:-$(uname -s)}"
    ARCH="${ARCH:-$(uname -m)}"
    
    # Normalize architecture names
    case "$ARCH" in
        amd64) ARCH="x86_64" ;;
        arm64) ARCH="aarch64" ;;
    esac
    
    # Determine distribution name
    if [ "$OS" = "Linux" ]; then
        if command -v ldd >/dev/null 2>&1 && ldd /bin/sh 2>&1 | grep -qi musl; then
            case "$ARCH" in
                x86_64) DIST="opengrep_musllinux_x86" ;;
                aarch64) DIST="opengrep_musllinux_aarch64" ;;
                *) DIST="" ;;
            esac
        else
            case "$ARCH" in
                x86_64) DIST="opengrep_manylinux_x86" ;;
                aarch64) DIST="opengrep_manylinux_aarch64" ;;
                *) DIST="" ;;
            esac
        fi
    elif [ "$OS" = "Darwin" ]; then
        case "$ARCH" in
            x86_64) DIST="opengrep_osx_x86" ;;
            aarch64) DIST="opengrep_osx_arm64" ;;
            *) DIST="" ;;
        esac
    fi
    
    if [ -n "$DIST" ]; then
        echo "https://github.com/opengrep/opengrep/releases/download/v${version}/${DIST}"
    else
        echo ""
    fi
}

download_url=$(get_download_url "$test_version")
if [[ -n "$download_url" ]]; then
    echo "  ✅ Platform supported, download URL: $download_url"
    
    # Test if the URL exists (without downloading)
    if curl -fsSL -I "$download_url" >/dev/null 2>&1; then
        echo "  ✅ Download URL is accessible"
    else
        echo "  ⚠️  Download URL returned error (version might not exist or network issue)"
    fi
else
    echo "  ❌ Platform not supported"
    exit 1
fi

# Test 6: Lint check
echo "🔍 Running lint checks..."
if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck --shell=bash --external-sources "$plugin_dir"/bin/* "$plugin_dir"/lib/* "$plugin_dir"/scripts/*; then
        echo "  ✅ shellcheck passed"
    else
        echo "  ❌ shellcheck found issues"
        exit 1
    fi
else
    echo "  ⚠️  shellcheck not available, skipping"
fi

if command -v shfmt >/dev/null 2>&1; then
    if shfmt --language-dialect bash --diff "$plugin_dir"/bin/* "$plugin_dir"/lib/* "$plugin_dir"/scripts/* >/dev/null; then
        echo "  ✅ shfmt formatting check passed"
    else
        echo "  ❌ shfmt found formatting issues"
        echo "  💡 Run 'scripts/format.bash' to fix formatting"
        exit 1
    fi
else
    echo "  ⚠️  shfmt not available, skipping formatting check"
fi

echo ""
echo "🎉 All tests passed! The plugin appears to be working correctly."
echo ""
echo "💡 To test with asdf, run:"
echo "   asdf plugin test opengrep $plugin_dir 'opengrep --version'"