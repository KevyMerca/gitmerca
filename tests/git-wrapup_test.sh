#!/bin/bash

# Mock the git command for testing
function git() {
    case "$1" in
        rev-parse)
            echo "feature-branch"
            ;;
        stash)
            echo "Stashed changes"
            ;;
        pull)
            if [ "$3" == "--rebase" ]; then
                echo "Rebased from develop"
            fi
            ;;
        add)
            echo "Staged all changes"
            ;;
        commit)
            if [ "$2" == "-m" ]; then
                echo "Committed with message: $3"
            fi
            ;;
        push)
            if [ "$2" == "--set-upstream" ]; then
                echo "Pushed to upstream branch: $4"
            fi
            ;;
        *)
            echo "Unknown git command"
            ;;
    esac
}

# Test case 1: Ensure the script exits if no commit message is provided
function test_no_commit_message() {
    output=$(./git-wrapup 2>&1)
    expected="Error: Commit message is required."
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 1 passed"
    else
        echo "Test case 1 failed"
    fi
}

# Test case 2: Ensure the script exits if run on the develop branch
function test_run_on_develop_branch() {
    function git() {
        if [ "$1" == "rev-parse" ]; then
            echo "develop"
        fi
    }
    output=$(./git-wrapup "Test commit" 2>&1)
    expected="Error: Cannot run this command on the develop or main branch."
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 2 passed"
    else
        echo "Test case 2 failed"
    fi
}

# Test case 3: Ensure the script exits if run on the main branch
function test_run_on_main_branch() {
    function git() {
        if [ "$1" == "rev-parse" ]; then
            echo "main"
        fi
    }
    output=$(./git-wrapup "Test commit" 2>&1)
    expected="Error: Cannot run this command on the develop or main branch."
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 3 passed"
    else
        echo "Test case 3 failed"
    fi
}

# Test case 4: Ensure the script stashes changes, rebases, and pops the stash
function test_stash_rebase_pop() {
    output=$(./git-wrapup "Test commit" 2>&1)
    expected="Stashed changes"
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 4 passed"
    else
        echo "Test case 4 failed"
    fi
}

# Test case 5: Ensure the script stages all changes and commits with the provided message
function test_stage_commit() {
    output=$(./git-wrapup "Test commit" 2>&1)
    expected="Committed with message: Test commit"
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 5 passed"
    else
        echo "Test case 5 failed"
    fi
}

# Test case 6: Ensure the script pushes the current branch upstream
function test_push_upstream() {
    output=$(./git-wrapup "Test commit" 2>&1)
    expected="Pushed to upstream branch: feature-branch"
    if [[ "$output" == *"$expected"* ]]; then
        echo "Test case 6 passed"
    else
        echo "Test case 6 failed"
    fi
}