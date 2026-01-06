#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Path to the command
SCRIPT_PATH="$COMMANDS_DIR/git-cleanup"

# ============================================================================
# Help and Version Tests (don't require git repo)
# ============================================================================

function test_help_option() {
    local output
    output=$("$SCRIPT_PATH" --help 2>&1)
    
    assert_contains "Usage: git cleanup [options]" "$output"
    assert_contains "-y, --yes" "$output"
    assert_contains "-h, --help" "$output"
}

function test_version_option() {
    local output
    output=$("$SCRIPT_PATH" --version 2>&1)
    
    assert_contains "Cleanup" "$output"
}

function test_unknown_option() {
    local output
    output=$("$SCRIPT_PATH" --invalid 2>&1)
    
    assert_contains "Error: Unknown option: --invalid" "$output"
}

# ============================================================================
# Git Repository Validation Tests
# ============================================================================

function test_requires_git_repo() {
    local test_dir
    test_dir=$(mktemp -d)
    
    local output
    output=$(cd "$test_dir" && "$SCRIPT_PATH" --yes 2>&1) || true
    
    assert_contains "Not a git repository" "$output"
    
    rm -rf "$test_dir"
}

# ============================================================================
# Functional Tests (require git repo)
# ============================================================================

function test_no_branches_to_delete() {
    local test_dir
    test_dir=$(mktemp -d)
    
    # Create a repo with only develop branch
    git -C "$test_dir" init --quiet
    git -C "$test_dir" config user.email "test@test.com"
    git -C "$test_dir" config user.name "Test User"
    git -C "$test_dir" checkout -b develop --quiet
    touch "$test_dir/.gitkeep"
    git -C "$test_dir" add .
    git -C "$test_dir" commit -m "Initial commit" --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" --yes 2>&1)
    
    assert_contains "No branches to clean up" "$output"
    
    rm -rf "$test_dir"
}

function test_shows_branches_to_delete() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create some branches
    git -C "$test_dir" checkout -b feature/old-branch --quiet
    git -C "$test_dir" checkout -b feature/test-branch --quiet
    git -C "$test_dir" checkout develop --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" --yes 2>&1)
    
    assert_contains "feature/old-branch" "$output"
    assert_contains "feature/test-branch" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_yes_flag_skips_confirmation() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create a branch to delete
    git -C "$test_dir" checkout -b feature/to-delete --quiet
    git -C "$test_dir" checkout develop --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" --yes 2>&1)
    
    # Should not ask for confirmation, should just delete
    assert_contains "Deleting branch" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_deletes_branches() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create branches
    git -C "$test_dir" checkout -b feature/to-delete --quiet
    git -C "$test_dir" checkout develop --quiet
    
    run_in_test_repo "$test_dir" "$SCRIPT_PATH" --yes >/dev/null 2>&1
    
    # Verify branch was deleted
    local branches
    branches=$(git -C "$test_dir" branch --list "feature/to-delete")
    
    assert_empty "$branches"
    
    cleanup_test_repo "$test_dir"
}

function test_preserves_develop() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create a branch and try to delete all
    git -C "$test_dir" checkout -b feature/test --quiet
    git -C "$test_dir" checkout develop --quiet
    
    run_in_test_repo "$test_dir" "$SCRIPT_PATH" --yes >/dev/null 2>&1
    
    # Verify develop still exists
    local has_develop
    has_develop=$(git -C "$test_dir" branch --list develop)
    
    assert_not_empty "$has_develop"
    
    cleanup_test_repo "$test_dir"
}

function test_warns_when_not_on_develop() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Switch to a feature branch
    git -C "$test_dir" checkout -b feature/current --quiet
    
    local output
    output=$(echo "n" | run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1)
    
    assert_contains "not on the develop branch" "$output"
    
    cleanup_test_repo "$test_dir"
}
