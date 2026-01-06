#!/bin/bash

# Get absolute paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/src/commands"
UTILS_DIR="$PROJECT_ROOT/src/utils"
TESTS_DIR="$PROJECT_ROOT/tests"
LIB_DIR="$PROJECT_ROOT/lib"

# Real git binary path (to avoid mock interference)
REAL_GIT="/usr/bin/git"

# Export paths
export PROJECT_ROOT COMMANDS_DIR UTILS_DIR TESTS_DIR LIB_DIR REAL_GIT

# ============================================================================
# Test Isolation Helpers
# ============================================================================

# Create an isolated test directory with a fake git repo
# Uses full path to git to avoid mock interference
# Usage: TEST_DIR=$(create_test_repo)
create_test_repo() {
    local test_dir
    test_dir=$(mktemp -d)
    
    # Initialize a minimal git repo using full path to avoid mocks
    $REAL_GIT -C "$test_dir" init --quiet
    $REAL_GIT -C "$test_dir" config user.email "test@test.com"
    $REAL_GIT -C "$test_dir" config user.name "Test User"
    
    # Create an initial commit so we have a valid repo state
    touch "$test_dir/.gitkeep"
    $REAL_GIT -C "$test_dir" add .
    $REAL_GIT -C "$test_dir" commit -m "Initial commit" --quiet
    
    # Create develop branch
    $REAL_GIT -C "$test_dir" checkout -b develop --quiet
    
    echo "$test_dir"
}

# Clean up test directory
# Usage: cleanup_test_repo "$TEST_DIR"
cleanup_test_repo() {
    local test_dir="$1"
    if [[ -d "$test_dir" && "$test_dir" == /tmp/* ]]; then
        rm -rf "$test_dir"
    fi
}

# Run a command in an isolated test directory
# Usage: output=$(run_in_test_repo "$TEST_DIR" "$COMMANDS_DIR/git-reform" --help)
run_in_test_repo() {
    local test_dir="$1"
    shift
    (cd "$test_dir" && "$@" 2>&1)
}
