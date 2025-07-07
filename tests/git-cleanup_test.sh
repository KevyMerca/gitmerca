#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Source the script to test
SCRIPT_PATH="$COMMANDS_DIR/git-cleanup"

# Default mock values
DEFAULT_BRANCHES="feature/old-branch\nfeature/test-branch\nfeature/unused"

# Reset mock state
function reset_mocks() {
    MOCK_BRANCHES="$DEFAULT_BRANCHES"
    MOCK_DELETE_SUCCESS=true
}

# Mock functions
function git() {
    case "$1" in
        "branch")
            if [ "$2" == "-D" ]; then
                if [ "$MOCK_DELETE_SUCCESS" = true ]; then
                    echo "Deleted branch: $3"
                    return 0
                else
                    echo "Failed to delete branch: $3" >&2
                    return 1
                fi
            else
                echo -e "* develop\n$MOCK_BRANCHES"
            fi
            ;;
        *)
            echo "Unknown git command: $1"
            return 1
            ;;
    esac
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
    local output
    output=$("$SCRIPT_PATH" --help 2>&1)
    assert_contains "Usage: git cleanup [options]" "$output"
    assert_contains "-y, --yes" "$output"
    assert_contains "-h, --help" "$output"
}

function test_unknown_option() {
    local output
    output=$("$SCRIPT_PATH" --invalid 2>&1)
    assert_contains "Error: Unknown option: --invalid" "$output"
}

function test_no_branches_to_delete() {
    MOCK_BRANCHES=""
    local output
    output=$("$SCRIPT_PATH" --yes 2>&1)
    assert_contains "No branches to clean up" "$output"
}

function test_shows_branches_to_delete() {
    local output
    output=$("$SCRIPT_PATH" --yes 2>&1)
    assert_contains "feature/old-branch" "$output"
    assert_contains "feature/test-branch" "$output"
    assert_contains "feature/unused" "$output"
    assert_contains "Total branches to delete:" "$output"
}

function test_yes_flag_skips_confirmation() {
    local output
    output=$("$SCRIPT_PATH" --yes 2>&1)
    assert_contains "Cleanup complete!" "$output"
}

function test_delete_failure() {
    MOCK_DELETE_SUCCESS=false
    local output
    output=$("$SCRIPT_PATH" --yes 2>&1) || true
    assert_contains "Failed to delete branch:" "$output"
}

function test_preserves_develop() {
    local output
    output=$("$SCRIPT_PATH" --yes 2>&1)
    assert_contains "The 'develop' branch will be preserved" "$output"
}
