#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Source the script to test
SCRIPT_PATH="$COMMANDS_DIR/git-reform"

# Default mock values
DEFAULT_BRANCH="feature/test-branch"
DEFAULT_BRANCHES="*develop
feature-branch
target-branch"
DEFAULT_HAS_CHANGES=true
DEFAULT_BRANCH_EXISTS=false

# Mock state
MOCK_BRANCH="$DEFAULT_BRANCH"
MOCK_BRANCHES="$DEFAULT_BRANCHES"
MOCK_HAS_CHANGES="$DEFAULT_HAS_CHANGES"
MOCK_BRANCH_EXISTS="$DEFAULT_BRANCH_EXISTS"
MOCK_EXIT_CODE=0

# Reset mock state
function reset_mocks() {
    MOCK_BRANCH="$DEFAULT_BRANCH"
    MOCK_BRANCHES="$DEFAULT_BRANCHES"
    MOCK_HAS_CHANGES="$DEFAULT_HAS_CHANGES"
    MOCK_BRANCH_EXISTS="$DEFAULT_BRANCH_EXISTS"
    MOCK_EXIT_CODE=0
}

# Mock functions
function git() {
    case "$1" in
        "rev-parse")
            if [ "$2" == "--abbrev-ref" ]; then
                echo "$MOCK_BRANCH"
            elif [ "$2" == "--git-dir" ]; then
                echo ".git"
            else
                echo "$MOCK_BRANCH"
            fi
            return 0
            ;;
        "diff-index")
            if [ "$MOCK_HAS_CHANGES" = true ]; then
                return 1
            else
                return 0
            fi
            ;;
        "show-ref")
            if [ "$2" == "--verify" ] && [ "$3" == "--quiet" ]; then
                if [ "$MOCK_BRANCH_EXISTS" = true ]; then
                    return 0
                else
                    return 1
                fi
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
            return 0
            ;;
        "stash")
            case "$2" in
                "pop")
                    echo "Popped stash"
                    ;;
                "save")
                    echo "Saved working directory and index state: $3"
                    ;;
                *)
                    echo "Changes stashed"
                    ;;
            esac
            return 0
            ;;
        "pull")
            if [ "$2" == "origin" ] && [ "$3" == "develop" ]; then
                if [ "$4" == "--rebase" ]; then
                    echo "Successfully rebased and updated refs/heads/$MOCK_BRANCH"
                    return 0
                fi
            fi
            echo "Current branch $MOCK_BRANCH is up to date."
            return 0
            ;;
        "rebase")
            echo "Rebased current branch"
            return 0
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
    assert_contains "Usage: git reform [options] [target-branch]" "$output"
    assert_contains "-f, --force" "$output"
    assert_contains "-h, --help" "$output"
}

function test_unknown_option() {
    local output
    output=$("$SCRIPT_PATH" --invalid 2>&1)
    assert_contains "Error: Unknown option: --invalid" "$output"
}

function test_no_changes() {
    MOCK_HAS_CHANGES=false
    local output
    output=$("$SCRIPT_PATH" --force 2>&1)
    assert_contains "No local changes to preserve" "$output"
    assert_contains "Reform complete!" "$output"
}

function test_with_changes() {
    MOCK_HAS_CHANGES=true
    local output
    output=$("$SCRIPT_PATH" --force 2>&1)
    assert_contains "Found changes to preserve" "$output"
    assert_contains "Stashing changes" "$output"
}

function test_new_target_branch() {
    MOCK_BRANCH_EXISTS=false
    local output
    output=$("$SCRIPT_PATH" --force new-branch 2>&1)
    assert_contains "Will create new branch: new-branch" "$output"
    assert_contains "Creating new branch: new-branch" "$output"
}

function test_existing_target_branch() {
    MOCK_BRANCH_EXISTS=true
    local output
    output=$("$SCRIPT_PATH" --force existing-branch 2>&1)
    assert_contains "Target branch exists" "$output"
    assert_contains "Switching to existing branch: existing-branch" "$output"
}

function test_develop_branch_behavior() {
    MOCK_BRANCH="develop"
    local output
    output=$("$SCRIPT_PATH" --force 2>&1)
    assert_contains "Updating develop branch" "$output"
    assert_contains "Reform complete!" "$output"
}

function test_force_flag() {
    MOCK_HAS_CHANGES=true
    local output
    output=$("$SCRIPT_PATH" --force 2>&1)
    assert_contains "Reform complete!" "$output"
}
