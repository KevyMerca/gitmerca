#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Source the script to test
SCRIPT_PATH="$COMMANDS_DIR/git-wrapup"

# Default mock values
DEFAULT_BRANCH="feature/test-branch"
DEFAULT_CHANGESET_EXIT_CODE=0
BRANCH_EXISTS=0

# Reset mock state
function reset_mocks() {
    MOCK_BRANCH="$DEFAULT_BRANCH"
    MOCK_CHANGESET_EXIT_CODE="$DEFAULT_CHANGESET_EXIT_CODE"
    BRANCH_EXISTS=0
}

# Mock functions
function git() {
    case "$1" in
        "rev-parse")
            if [ "$2" == "--abbrev-ref" ] && [ "$3" == "HEAD" ]; then
                echo "$MOCK_BRANCH"
            else
                echo "Unknown rev-parse args"
                return 1
            fi
            ;;
        "show-ref")
            if [ "$2" == "--verify" ] && [ "$3" == "--quiet" ]; then
                return "$BRANCH_EXISTS"
            fi
            ;;
        "checkout")
            if [ "$2" == "-b" ]; then
                echo "Created and switched to branch: $3"
                MOCK_BRANCH="$3"
            else
                echo "Switched to branch: $2"
                MOCK_BRANCH="$2"
            fi
            ;;
        "stash")
            if [ "$2" == "pop" ]; then
                echo "Popped stash"
            elif [ "$2" == "-u" ]; then
                echo "Stashed changes including untracked files"
            else
                echo "Stashed changes"
            fi
            ;;
        "pull")
            if [ "$2" == "origin" ] && [ "$3" == "develop" ] && [ "$4" == "--rebase" ]; then
                echo "Pulled from develop with rebase"
            else
                echo "Invalid pull command"
                return 1
            fi
            ;;
        "add")
            echo "Staged changes"
            ;;
        "commit")
            if [ "$2" == "-m" ]; then
                echo "Committed: $3"
            else
                echo "Invalid commit command"
                return 1
            fi
            ;;
        "push")
            if [ "$2" == "--set-upstream" ] && [ "$3" == "origin" ]; then
                echo "Pushed to: $4"
            else
                echo "Invalid push command"
                return 1
            fi
            ;;
        *)
            echo "Unknown git command: $1"
            return 1
            ;;
    esac
    return 0
}

function pnpm() {
    if [ "$1" == "changeset" ]; then
        return "$MOCK_CHANGESET_EXIT_CODE"
    fi
}

# Setup and teardown
function setUp() {
    reset_mocks
}

function tearDown() {
    :
}

# Test cases
function test_help_option() {
    local output=$("$SCRIPT_PATH" --help 2>&1)
    assert_contains "Usage: git wrapup [options] <commit-message>" "$output"
    assert_contains "-b, --branch <branch-name>" "$output"
}

function test_commit_message_required() {
    local output=$("$SCRIPT_PATH" 2>&1)
    assert_contains "Error: Commit message is required" "$output"
}

function test_protected_branches_without_branch_option() {
    local protected_branches=("develop" "main")
    
    for branch in "${protected_branches[@]}"; do
        MOCK_BRANCH="$branch"
        local output=$("$SCRIPT_PATH" "test commit" 2>&1)
        assert_contains "Error: Cannot run this command on develop or main branch without --branch option" "$output"
    done
}

function test_protected_branches_with_branch_option() {
    local protected_branches=("develop" "main")
    
    for branch in "${protected_branches[@]}"; do
        MOCK_BRANCH="$branch"
        local output=$("$SCRIPT_PATH" -b "feature/new-thing" "test commit" 2>&1)
        assert_contains "Creating new branch: feature/new-thing" "$output"
        assert_contains "Committed: test commit" "$output"
    done
}

function test_branch_option_existing_branch() {
    MOCK_BRANCH="develop"
    BRANCH_EXISTS=0  # Branch exists
    local output=$("$SCRIPT_PATH" -b "feature/existing" "test commit" 2>&1)
    assert_contains "Switching to existing branch: feature/existing" "$output"
}

function test_branch_option_new_branch() {
    MOCK_BRANCH="develop"
    BRANCH_EXISTS=1  # Branch doesn't exist
    local output=$("$SCRIPT_PATH" -b "feature/new-branch" "test commit" 2>&1)
    assert_contains "Creating new branch: feature/new-branch" "$output"
}

function test_branch_option_missing_name() {
    local output=$("$SCRIPT_PATH" -b 2>&1)
    assert_contains "Branch name is required for -b|--branch option" "$output"
}

function test_stash_with_untracked() {
    local output=$("$SCRIPT_PATH" "test commit" 2>&1)
    assert_contains "Stashed changes including untracked files" "$output"
}

function test_successful_workflow() {
    local output=$("$SCRIPT_PATH" "test commit" 2>&1)
    assert_contains "Starting wrapup process for branch:" "$output"
    assert_contains "Pulling and rebasing from develop" "$output"
    assert_contains "Committed: test commit" "$output"
    assert_contains "Wrapup complete!" "$output"
}

function test_changeset_failure() {
    MOCK_CHANGESET_EXIT_CODE=1
    local output=$("$SCRIPT_PATH" "test commit" 2>&1)
    assert_contains "Error: pnpm changeset command failed" "$output"
}