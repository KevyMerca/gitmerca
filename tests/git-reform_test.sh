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

# Mock state
MOCK_BRANCH="$DEFAULT_BRANCH"
MOCK_BRANCHES="$DEFAULT_BRANCHES"
MOCK_EXIT_CODE=0

# Reset mock state
function reset_mocks() {
    MOCK_BRANCH="$DEFAULT_BRANCH"
    MOCK_BRANCHES="$DEFAULT_BRANCHES"
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
        "checkout")
            if [ "$2" == "-b" ]; then
                echo "Switched to a new branch '$3'"
            else
                echo "Switched to branch '$2'"
            fi
            return 0
            ;;
        "stash")
            case "$2" in
                "pop")
                    echo "Popped stash"
                    ;;
                "save")
                    echo "Saved working directory and index state"
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
        "branch")
            if [ "$2" == "--list" ]; then
                echo "$MOCK_BRANCHES"
            elif [ "$2" == "-D" ]; then
                echo "Deleted branch $3"
            else
                echo "$MOCK_BRANCHES"
            fi
            return 0
            ;;
        "fetch")
            echo "Fetching origin"
            return 0
            ;;
        "remote")
            if [ "$2" == "get-url" ]; then
                echo "git@github.com:test-org/test-repo.git"
            elif [ "$2" == "update" ]; then
                echo "Remote updated"
            fi
            return 0
            ;;
        "config")
            case "$2" in
                "--get")
                    if [ "$3" == "branch.$MOCK_BRANCH.remote" ]; then
                        echo "origin"
                    elif [ "$3" == "branch.$MOCK_BRANCH.merge" ]; then
                        echo "refs/heads/$MOCK_BRANCH"
                    elif [ "$3" == "remote.origin.url" ]; then
                        echo "git@github.com:test-org/test-repo.git"
                    fi
                    ;;
                *)
                    echo "config $2 $3=$4"
                    ;;
            esac
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
function test_basic_reform() {
    local output=$("$SCRIPT_PATH" 2>&1)
    assert_contains "Changes stashed" "$output"
    assert_contains "Successfully rebased" "$output"
}

function test_existing_target_branch() {
    local output=$("$SCRIPT_PATH" "target-branch" 2>&1)
    assert_contains "Changes stashed" "$output"
    assert_contains "Switched to branch 'target-branch'" "$output"
    assert_contains "Successfully rebased" "$output"
}

function test_new_target_branch() {
    local output=$("$SCRIPT_PATH" "new-feature" 2>&1)
    assert_contains "Changes stashed" "$output"
    assert_contains "Switched to a new branch 'new-feature'" "$output"
    assert_contains "Successfully rebased" "$output"
}

function test_develop_branch() {
    MOCK_BRANCH="develop"
    local output=$("$SCRIPT_PATH" 2>&1)
    assert_contains "Changes stashed" "$output"
    assert_contains "Successfully rebased" "$output"
}

function test_invalid_branch_name() {
    MOCK_EXIT_CODE=1
    local output=$("$SCRIPT_PATH" "invalid/branch?name" 2>&1)
    assert_contains "Error: Invalid branch name" "$output"
    [ "$?" -eq 1 ] && assert_success
}
