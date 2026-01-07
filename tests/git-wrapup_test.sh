#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Path to the command
SCRIPT_PATH="$COMMANDS_DIR/git-wrapup"

# ============================================================================
# Help and Version Tests (don't require git repo)
# ============================================================================

function test_help_option() {
    local output
    output=$("$SCRIPT_PATH" --help 2>&1)
    
    assert_contains "Usage: git wrapup [options] <commit-message>" "$output"
    assert_contains "-b, --branch <branch-name>" "$output"
    assert_contains "-f, --from <branch>" "$output"
    assert_contains "-n, --no-changeset" "$output"
    assert_contains "-h, --help" "$output"
    assert_contains "-v, --version" "$output"
}

function test_version_option() {
    local output
    output=$("$SCRIPT_PATH" --version 2>&1)
    
    assert_contains "Wrapup" "$output"
}

function test_commit_message_required() {
    local output
    output=$("$SCRIPT_PATH" 2>&1)
    
    assert_contains "Error: Commit message is required" "$output"
}

function test_branch_option_missing_name() {
    local output
    output=$("$SCRIPT_PATH" -b 2>&1)
    
    assert_contains "Branch name is required for -b|--branch option" "$output"
}

function test_from_option_missing_name() {
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
    output=$(cd "$test_dir" && "$SCRIPT_PATH" "test commit" 2>&1) || true
    
    assert_contains "Not a git repository" "$output"
    
    rm -rf "$test_dir"
}

# ============================================================================
# Protected Branch Tests
# ============================================================================

function test_cannot_commit_to_develop() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Make sure we're on develop
    git -C "$test_dir" checkout develop --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" "test commit" 2>&1) || true
    
    assert_contains "Cannot commit directly to develop" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_cannot_commit_to_main() {
    local test_dir
    test_dir=$(mktemp -d)
    
    # Initialize repo with main as default branch
    git -C "$test_dir" init --quiet
    git -C "$test_dir" config user.email "test@test.com"
    git -C "$test_dir" config user.name "Test User"
    git -C "$test_dir" checkout -b main --quiet
    touch "$test_dir/.gitkeep"
    git -C "$test_dir" add .
    git -C "$test_dir" commit -m "Initial commit" --quiet
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" "test commit" 2>&1) || true
    
    assert_contains "Cannot commit directly to main" "$output"
    
    rm -rf "$test_dir"
}

function test_branch_option_allows_from_develop() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Stay on develop, create a file to commit
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -b "feature/new" -n "feat: test" 2>&1) || true
    
    # Should not error about develop, should try to create branch
    assert_contains "Creating new branch: feature/new" "$output"
    
    cleanup_test_repo "$test_dir"
}

# ============================================================================
# Functional Tests
# ============================================================================

function test_shows_current_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "feat: test" 2>&1) || true
    
    assert_contains "Current branch: feature/test" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_no_changeset_option() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "feat: test" 2>&1) || true
    
    assert_contains "Skipping changeset (--no-changeset)" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_stages_changes() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "feat: test" 2>&1) || true
    
    assert_contains "Staging changes" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_creates_commit() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "feat: test commit" 2>&1) || true
    
    assert_contains "Creating commit" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_warns_on_non_conventional_commit() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "bad commit message" 2>&1) || true
    
    assert_contains "doesn't follow conventional commits format" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_switch_to_existing_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    # Create target branch
    git -C "$test_dir" checkout -b feature/existing --quiet
    git -C "$test_dir" checkout develop --quiet
    
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -b "feature/existing" -n "feat: test" 2>&1) || true
    
    assert_contains "Switching to existing branch: feature/existing" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_create_new_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -b "feature/new-branch" -n "feat: test" 2>&1) || true
    
    assert_contains "Creating new branch: feature/new-branch" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_from_option_shows_base_branch() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -f "main" -n "feat: test" --dry-run 2>&1) || true
    
    assert_contains "Base branch for PR: main" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_from_option_defaults_to_develop() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -n "feat: test" --dry-run 2>&1) || true
    
    assert_contains "Base branch for PR: develop" "$output"
    
    cleanup_test_repo "$test_dir"
}

function test_from_option_in_dry_run() {
    local test_dir
    test_dir=$(create_test_repo)
    
    git -C "$test_dir" checkout -b feature/test --quiet
    echo "test" > "$test_dir/test.txt"
    
    local output
    output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" -f "staging" -n "feat: test" --dry-run 2>&1) || true
    
    assert_contains "Base branch for PR: staging" "$output"
    assert_contains "Open pull request URL in browser (base: staging)" "$output"
    
    cleanup_test_repo "$test_dir"
}
