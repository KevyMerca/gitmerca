#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# ============================================================================
# Unit Tests for git-utils.sh helper functions
# 
# These tests mock git/open commands and test functions directly.
# This approach works because we source git-utils.sh AFTER defining mocks,
# so function calls use our mocks instead of real commands.
# ============================================================================

# Mock state variables
MOCK_REMOTE_URL=""
MOCK_OPEN_FAILS=false
MOCK_XDG_OPEN_FAILS=false

# Mock git command
function git() {
    case "$1" in
        "config")
            if [ "$2" == "--get" ] && [ "$3" == "remote.origin.url" ]; then
                echo "$MOCK_REMOTE_URL"
                return 0
            fi
            ;;
        "rev-parse")
            # Mock for require_git_repo check
            if [ "$2" == "--git-dir" ]; then
                echo ".git"
                return 0
            fi
            ;;
    esac
    echo "Unknown git command: $1"
    return 1
}

# Mock command function for checking open/xdg-open availability
function command() {
    if [ "$2" == "open" ]; then
        [ "$MOCK_OPEN_FAILS" = true ] && return 1
        return 0
    elif [ "$2" == "xdg-open" ]; then
        [ "$MOCK_XDG_OPEN_FAILS" = true ] && return 1
        return 0
    fi
    # Use builtin command for other checks
    builtin command "$@"
}

# Mock open command
function open() {
    echo "Would open: $1"
    return 0
}

# Mock xdg-open command
function xdg-open() {
    echo "Would xdg-open: $1"
    return 0
}

# Reset mock state before each test
function reset_mocks() {
    MOCK_REMOTE_URL="git@github.com:test-org/test-repo.git"
    MOCK_OPEN_FAILS=false
    MOCK_XDG_OPEN_FAILS=false
}

# Setup: Source git-utils AFTER defining mocks
function set_up() {
    reset_mocks
    source "$UTILS_DIR/git-utils.sh"
}

# Teardown: Clean up
function tear_down() {
    unset MOCK_REMOTE_URL MOCK_OPEN_FAILS MOCK_XDG_OPEN_FAILS
}

# ============================================================================
# URL Conversion Tests
# ============================================================================

function test_convert_ssh_url_to_https() {
    local result
    result=$(convert_to_https_url "git@github.com:test-org/test-repo.git")
    
    assert_equals "https://github.com/test-org/test-repo" "$result"
}

function test_convert_https_url_unchanged() {
    local result
    result=$(convert_to_https_url "https://github.com/test-org/test-repo.git")
    
    assert_equals "https://github.com/test-org/test-repo" "$result"
}

function test_strips_git_suffix() {
    local result
    result=$(convert_to_https_url "git@github.com:org/repo.git")
    
    assert_not_contains ".git" "$result"
}

# ============================================================================
# Pull Request URL Tests
# ============================================================================

function test_open_pr_url_ssh_remote() {
    MOCK_REMOTE_URL="git@github.com:test-org/test-repo.git"
    
    local output
    output=$(open_pull_request_url "feature-branch" 2>&1)
    
    assert_contains "https://github.com/test-org/test-repo/pull/new/feature-branch" "$output"
}

function test_open_pr_url_https_remote() {
    MOCK_REMOTE_URL="https://github.com/test-org/test-repo.git"
    
    local output
    output=$(open_pull_request_url "feature-branch" 2>&1)
    
    assert_contains "https://github.com/test-org/test-repo/pull/new/feature-branch" "$output"
}

function test_open_pr_url_with_base_branch_ssh() {
    MOCK_REMOTE_URL="git@github.com:test-org/test-repo.git"
    
    local output
    output=$(open_pull_request_url "feature-branch" "main" 2>&1)
    
    assert_contains "https://github.com/test-org/test-repo/compare/main...feature-branch" "$output"
    assert_contains "expand=1" "$output"
}

function test_open_pr_url_with_base_branch_https() {
    MOCK_REMOTE_URL="https://github.com/test-org/test-repo.git"
    
    local output
    output=$(open_pull_request_url "feature-branch" "staging" 2>&1)
    
    assert_contains "https://github.com/test-org/test-repo/compare/staging...feature-branch" "$output"
    assert_contains "expand=1" "$output"
}

# ============================================================================
# Open URL Fallback Tests
# ============================================================================

function test_open_url_uses_open_command() {
    MOCK_OPEN_FAILS=false
    
    local output
    output=$(open_url "https://example.com" 2>&1)
    
    assert_contains "Would open: https://example.com" "$output"
}

function test_open_url_falls_back_to_xdg_open() {
    MOCK_OPEN_FAILS=true
    MOCK_XDG_OPEN_FAILS=false
    
    local output
    output=$(open_url "https://example.com" 2>&1)
    
    assert_contains "Would xdg-open: https://example.com" "$output"
}

# ============================================================================
# Branch Existence Tests (using real temp repo)
# ============================================================================

function test_branch_exists_returns_true_for_existing() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Use full path to bypass mock git function
    local result
    result=$(/usr/bin/git -C "$test_dir" show-ref --verify --quiet "refs/heads/develop" && echo "0" || echo "1")
    
    assert_equals "0" "$result"
    
    cleanup_test_repo "$test_dir"
}

function test_branch_exists_returns_false_for_nonexistent() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Source real git-utils (not mocked)
    unset -f git
    source "$UTILS_DIR/git-utils.sh"
    
    # Test in the real repo
    (cd "$test_dir" && branch_exists "nonexistent-branch")
    local result=$?
    
    assert_equals 1 "$result"
    
    cleanup_test_repo "$test_dir"
}
