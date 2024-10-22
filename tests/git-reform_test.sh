#!/bin/bash

# Test case 1: Test git-reform without a target branch on a non-develop branch
function test_git_reform_no_target_branch_non_develop() {
    # Setup: Create a temporary Git repository
    temp_repo=$(mktemp -d)
    cd "$temp_repo"
    git init
    touch file.txt
    git add file.txt
    git commit -m "Initial commit"
    git checkout -b feature-branch

    # Run the git-reform command
    output=$(git-reform 2>&1)
    exit_code=$?

    # Assert: Check if the command succeeded and the output is as expected
    assert_same "0" "$exit_code"
    assert_contains "Auto-stash before rebase" "$output"
    assert_contains "Rebasing" "$output"

    # Cleanup
    cd -
    rm -rf "$temp_repo"
}

# Test case 2: Test git-reform with a target branch that exists
function test_git_reform_with_existing_target_branch() {
    # Setup: Create a temporary Git repository
    temp_repo=$(mktemp -d)
    cd "$temp_repo"
    git init
    touch file.txt
    git add file.txt
    git commit -m "Initial commit"
    git checkout -b feature-branch
    git checkout -b target-branch

    # Run the git-reform command with the target branch
    output=$(git-reform target-branch 2>&1)
    exit_code=$?

    # Assert: Check if the command succeeded and the output is as expected
    assert_same "0" "$exit_code"
    assert_contains "Auto-stash before rebase" "$output"
    assert_contains "Switched to branch 'target-branch'" "$output"

    # Cleanup
    cd -
    rm -rf "$temp_repo"
}

# Test case 3: Test git-reform with a target branch that does not exist
function test_git_reform_with_non_existing_target_branch() {
    # Setup: Create a temporary Git repository
    temp_repo=$(mktemp -d)
    cd "$temp_repo"
    git init
    touch file.txt
    git add file.txt
    git commit -m "Initial commit"
    git checkout -b feature-branch

    # Run the git-reform command with a non-existing target branch
    output=$(git-reform new-branch 2>&1)
    exit_code=$?

    # Assert: Check if the command succeeded and the output is as expected
    assert_same "0" "$exit_code"
    assert_contains "Auto-stash before rebase" "$output"
    assert_contains "Switched to a new branch 'new-branch'" "$output"

    # Cleanup
    cd -
    rm -rf "$temp_repo"
}

# Test case 4: Test git-reform on the develop branch
function test_git_reform_on_develop_branch() {
    # Setup: Create a temporary Git repository
    temp_repo=$(mktemp -d)
    cd "$temp_repo"
    git init
    touch file.txt
    git add file.txt
    git commit -m "Initial commit"
    git checkout -b develop

    # Run the git-reform command on the develop branch
    output=$(git-reform 2>&1)
    exit_code=$?

    # Assert: Check if the command succeeded and the output is as expected
    assert_same "0" "$exit_code"
    assert_contains "Rebasing" "$output"

    # Cleanup
    cd -
    rm -rf "$temp_repo"
}
