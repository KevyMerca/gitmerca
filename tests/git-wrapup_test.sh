#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Source the script to test
SCRIPT_PATH="$COMMANDS_DIR/git-wrapup"

# Default mock values
DEFAULT_BRANCH="feature/test-branch"
DEFAULT_CHANGESET_EXIT_CODE=0

# Reset mock state
function reset_mocks() {
    MOCK_BRANCH="$DEFAULT_BRANCH"
    MOCK_CHANGESET_EXIT_CODE="$DEFAULT_CHANGESET_EXIT_CODE"
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
        "stash")
            if [ "$1" == "pop" ]; then
                echo "Popped stash"
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
function test_commit_message_required() {
    local output=$("$SCRIPT_PATH" 2>&1)
    assert_contains "Error: Commit message is required" "$output"
}

function test_protected_branches() {
    local protected_branches=("develop" "main")
    
    for branch in "${protected_branches[@]}"; do
        MOCK_BRANCH="$branch"
        local output=$("$SCRIPT_PATH" "test commit" 2>&1)
        assert_contains "Error: Cannot run this command on the develop or main branch" "$output"
    done
}

function test_normal_workflow() {
    local output=$("$SCRIPT_PATH" "test commit message" 2>&1)
    
    assert_contains "Stashed changes" "$output"
    assert_contains "Pulled from develop with rebase" "$output"
    assert_contains "Committed: test commit message" "$output"
    assert_contains "Pushed to: $MOCK_BRANCH" "$output"
}

function test_changeset_failure() {
    MOCK_CHANGESET_EXIT_CODE=1
    local output=$("$SCRIPT_PATH" "test commit" 2>&1)
    assert_contains "Error: pnpm changeset command failed" "$output"
}