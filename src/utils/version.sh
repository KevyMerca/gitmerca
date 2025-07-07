#!/bin/bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read version from package.json
if command -v node >/dev/null 2>&1; then
    VERSION=$(node -p "require('$SCRIPT_DIR/../../package.json').version" 2>/dev/null)
else
    # Fallback to grep/sed if node is not available
    VERSION=$(grep -m 1 '"version":' "$SCRIPT_DIR/../../package.json" | sed 's/[^0-9.]//g')
fi

VERSION=${VERSION:-"unknown"}

# Function to print version
print_version() {
    echo "Gitmerca v${VERSION}"
    echo "Custom git commands for mercateam contributors"
}
