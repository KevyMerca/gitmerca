#!/bin/bash

# Get the directory of this script and initialize variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
PACKAGE_JSON=""

# Try different possible locations for package.json
if [[ -f "$SCRIPT_DIR/../../package.json" ]]; then
    # Development environment (src/utils)
    PACKAGE_JSON="$SCRIPT_DIR/../../package.json"
elif [[ -f "$INSTALL_DIR/package.json" ]]; then
    # Installation root directory
    PACKAGE_JSON="$INSTALL_DIR/package.json"
elif [[ "$SCRIPT_DIR" =~ /utils$ ]] && [[ -f "$(dirname "$SCRIPT_DIR")/package.json" ]]; then
    # Utils directory without src
    PACKAGE_JSON="$(dirname "$SCRIPT_DIR")/package.json"
else
    # Fallback to searching up the directory tree
    current_dir="$SCRIPT_DIR"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/package.json" ]]; then
            PACKAGE_JSON="$current_dir/package.json"
            break
        fi
        current_dir="$(dirname "$current_dir")"
    done
fi

# If no package.json found, set error message
if [[ -z "$PACKAGE_JSON" ]]; then
    echo "Error: Could not find package.json in any location" >&2
    VERSION="unknown"
    export VERSION
    return 0
fi

# Read version from package.json if we found it
if [[ -n "$PACKAGE_JSON" ]] && [[ -f "$PACKAGE_JSON" ]]; then
    # Read version from package.json
    if command -v node >/dev/null 2>&1; then
        VERSION=$(node -p "require('$PACKAGE_JSON').version" 2>/dev/null)
    else
        # Fallback to grep/sed if node is not available
        VERSION=$(grep -m 1 '"version":' "$PACKAGE_JSON" | sed -E 's/.*"version":[[:space:]]*"([^"]+)".*/\1/')
    fi
    
    if [[ -z "$VERSION" ]]; then
        echo "Error: Could not read version from package.json" >&2
        VERSION="unknown"
    fi
fi

export VERSION

# Function to get version
get_version() {
    echo "v${VERSION}"
}

# Function to print version (legacy support)
print_version() {
    echo "Gitmerca v${VERSION}"
    echo "Custom git commands for mercateam contributors"
}

# Export the functions
export -f get_version
export -f print_version
