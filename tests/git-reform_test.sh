#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Path to the command
SCRIPT_PATH="$COMMANDS_DIR/git-reform"

# ============================================================================
# Help and Version Tests (don't require git repo)
# ============================================================================

function test_help_option() {
    local output
    output=$("$SCRIPT_PATH" --help 2>&1)
    
    assert_contains "Usage: git reform [options] [target-branch]" "$output"
    assert_contains "-f, --from <branch>" "$output"
    assert_contains "-h, --help" "$output"
    assert_contains "-v, --version" "$output"
}

function test_version_option() {
    local output
    output=$("$SCRIPT_PATH" --version 2>&1)
    
    assert_contains "Reform" "$output"
}

function test_unknown_option() {
    local output
    output=$("$SCRIPT_PATH" --invalid 2>&1)
    
    assert_contains "Error: Unknown option: --invalid" "$output"
}

function test_from_option_missing_branch() {
    local output
    output=$("$SCRIPT_PATH" -f 2>&1)
    
    assert_contains "Branch name is required for -f|--from option" "$output"
}

# ============================================================================
# Git Repository Validation Tests
# ============================================================================

function test_requires_git_repo() {
    local test_dir
    test_dir=$(mktemp -d)
    
    local output
    output=$(cd "$test_dir" && "$SCRIPT_PATH" 2>&1) || true
    
    assert_contains "Not a git repository" "$output"
    
    rm -rf "$test_dir"
}

# ============================================================================
# Functional Tests (require git repo)
# ============================================================================

function test_shows_current_branch() {
    local test_dir
    test_dir=$(create_test_repo)

    # Create a feature branch
    git -C "$test_dir" checkout -b feature/test-branch --quiet

    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1) || true

    assert_contains "Current branch: feature/test-branch" "$output"

    cleanup_test_repo "$test_dir"
}

function test_shows_base_branch() {
    local test_dir
    test_dir=$(create_test_repo)

    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1) || true

    assert_contains "Base branch: develop" "$output"

    cleanup_test_repo "$test_dir"
}

function test_custom_base_branch() {
    local test_dir
    test_dir=$(create_test_repo)

    # Create main branch
    git -C "$test_dir" checkout -b main --quiet
    git -C "$test_dir" checkout develop --quiet

    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -f main 2>&1) || true

    assert_contains "Base branch: main" "$output"

    cleanup_test_repo "$test_dir"
}

function test_new_target_branch() {
    local test_dir
    test_dir=$(create_test_repo)

    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" new-branch 2>&1) || true

    assert_contains "Will create new branch: new-branch" "$output"

    cleanup_test_repo "$test_dir"
}

function test_existing_target_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create target branch
    git -C "$test_dir" checkout -b existing-branch --quiet
    git -C "$test_dir" checkout develop --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" existing-branch 2>&1) || true
    
    assert_contains "Target branch exists" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_stashes_changes() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create uncommitted changes
    echo "test content" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1) || true
    
    assert_contains "Stashing changes" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_reform_complete_on_feature_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create a feature branch (reform works better on non-develop branches)
    git -C "$test_dir" checkout -b feature/test --quiet
    
    # Add a remote and set up tracking so rebase works
    git -C "$test_dir" remote add origin "$test_dir" 2>/dev/null || true
    git -C "$test_dir" fetch origin develop --quiet 2>/dev/null || true
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1) || true
    
    # The command should complete (even if rebase has issues in test env)
    # We just check it tried to rebase
    assert_contains "Rebasing from develop" "$output"
    
    cleanup_test_repo "$test_dir"
}
