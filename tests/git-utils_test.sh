#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Mock functions
function git() {
    case "$1" in
        "config")
            if [ "$2" == "--get" ] && [ "$3" == "remote.origin.url" ]; then
                echo "$MOCK_REMOTE_URL"
                return 0
            fi
            ;;
    esac
    echo "Unknown git command: $1"
    return 1
}

# Mock the command function that git-utils uses to check for open/xdg-open
function command() {
    if [ "$2" == "open" ]; then
        if [ "$MOCK_OPEN_FAILS" = true ]; then
            return 1
        fi
        return 0
    elif [ "$2" == "xdg-open" ]; then
        if [ "$MOCK_XDG_OPEN_FAILS" = true ]; then
            return 1
        fi
        return 0
    fi
    return 1
}

# Mock the actual open/xdg-open commands
function open() {
    echo "Would open: $1"
    return 0
}

function xdg-open() {
    echo "Would xdg-open: $1"
    return 0
}

# Reset mock state
function reset_mocks() {
    MOCK_REMOTE_URL="git@github.com:test-org/test-repo.git"
    MOCK_OPEN_FAILS=false
    MOCK_XDG_OPEN_FAILS=false
}

# Setup and teardown
function setUp() {
    reset_mocks
    # Source git-utils after setting up mocks
    source "$UTILS_DIR/git-utils"
}

function tearDown() {
    # Unset mock functions and variables to avoid conflicts with bashunit
    unset -f git
    unset -f command
    unset -f open
    unset -f xdg-open
    unset -f reset_mocks
    unset MOCK_REMOTE_URL
    unset MOCK_OPEN_FAILS
    unset MOCK_XDG_OPEN_FAILS
    unset DEFAULT_REMOTE_URL
    
    # Clean up bashunit variables
    unset BASHUNIT_GIT_REPO
    unset BASHUNIT_REMOTE_NAME
    unset BASHUNIT_COMMITS_AHEAD
    unset BASHUNIT_REMOTE_URL
}

# Test cases
function test_ssh_url_conversion() {
    echo "🧪 Running SSH URL conversion test..."
    local output=$(open_pull_request_url "feature-branch" 2>&1)
    assert_same "Would open: https://github.com/test-org/test-repo/pull/new/feature-branch" "$output" "SSH URL conversion"
    echo "✅ SSH URL conversion test passed"
}

function test_https_url_handling() {
    echo "🧪 Running HTTPS URL handling test..."
    MOCK_REMOTE_URL="https://github.com/test-org/test-repo.git"
    local output=$(open_pull_request_url "feature-branch" 2>&1)
    assert_same "Would open: https://github.com/test-org/test-repo/pull/new/feature-branch" "$output" "HTTPS URL handling"
    echo "✅ HTTPS URL handling test passed"
}

function test_url_opening_fallback() {
    echo "🧪 Running URL opening fallback test..."
    MOCK_OPEN_FAILS=true
    local output=$(open_pull_request_url "feature-branch" 2>&1)
    assert_same "Would xdg-open: https://github.com/test-org/test-repo/pull/new/feature-branch" "$output" "URL opening fallback"
    echo "✅ URL opening fallback test passed"
}

# Run all tests
echo "🧪 Testing git-utils..."
source "$LIB_DIR/test/bashunit"
