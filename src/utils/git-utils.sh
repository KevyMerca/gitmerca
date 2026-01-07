#!/bin/bash

# Source core utilities
source "$(dirname "${BASH_SOURCE[0]}")/core-utils.sh"

# Validate that we're in a git repository
require_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        error_exit "Not a git repository. Please run this command from within a git repository."
    fi
}

# Convert Git remote URL to HTTPS format
convert_to_https_url() {
    local remote_url="$1"
    local repo_path

    if [[ $remote_url == git@* ]]; then
        repo_path=$(echo "$remote_url" | sed 's/git@github.com://' | sed 's/\.git$//')
    else
        repo_path=$(echo "$remote_url" | sed 's/https:\/\/github.com\///' | sed 's/\.git$//')
    fi

    echo "https://github.com/$repo_path"
}

# Get the remote URL for the current repository
get_remote_url() {
    git config --get remote.origin.url || {
        print_error "Failed to get remote URL. Are you in a git repository?"
        return 1
    }
}

# Open URL using the system's default browser
open_url() {
    local url="$1"
    
    if command -v open >/dev/null 2>&1; then
        open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
    else
        print_error "Could not find a way to open URLs. Please open manually: $url"
        return 1
    fi
}

# Helper function to open pull request URL
# Args: branch [base_branch]
open_pull_request_url() {
    local branch="$1"
    local base_branch="${2:-}"
    
    # Get the remote URL
    local remote_url
    remote_url=$(get_remote_url) || return 1
    
    # Convert to HTTPS if necessary
    local base_url
    base_url=$(convert_to_https_url "$remote_url")
    
    # Construct and open the pull request URL
    local pr_url
    if [[ -n "$base_branch" ]]; then
        # Use compare format when base branch is specified: compare/base...head
        pr_url="$base_url/compare/$base_branch...$branch?expand=1"
    else
        # Use default format: pull/new/head
        pr_url="$base_url/pull/new/$branch"
    fi
    
    print_info "Opening pull request URL: $pr_url"
    open_url "$pr_url"
}

# Function to check if branch exists
branch_exists() {
    git show-ref --verify --quiet "refs/heads/$1"
}

# Function to handle target branch
handle_target_branch() {
    local target="$1"
    
    if branch_exists "$target"; then
        print_info "⚡ Switching to existing branch: ${target}"
        if ! git checkout "$target"; then
            error_exit "Failed to switch to $target"
        fi
    else
        print_info "✨ Creating new branch: ${target}"
        if ! git checkout -b "$target"; then
            error_exit "Failed to create branch $target"
        fi
    fi
}

# Function to check commit message format
validate_commit_message() {
    local msg="$1"
    local pattern="^(feat|fix|docs|style|refactor|test|chore)(\([a-z-]+\))?: .+"
    
    if [[ ! $msg =~ $pattern ]]; then
        print_warning "Commit message doesn't follow conventional commits format (type: description)"
        print_info "Continuing anyway..."
    fi
}

# Function to stage and commit changes
commit_changes() {
    local msg="$1"
    
    print_info "📦 Staging changes..."
    if ! git add .; then
        error_exit "Failed to stage changes"
    fi
    
    print_info "💾 Creating commit..."
    if ! git commit -m "$msg"; then
        error_exit "Failed to create commit"
    fi
}

# Function to push changes with upstream tracking
push_changes() {
    local branch="$1"
    
    print_info "📤 Pushing changes..."
    if ! git push -u origin "$branch"; then
        error_exit "Failed to push changes to remote"
    fi
}

# Function to get list of branches except develop
get_branches_except_develop() {
    git branch --format="%(refname:short)" | grep -v "^develop$" || true
}

# Function to delete branches
delete_branches() {
    local branches=("$@")
    local deleted=0
    local failed=0
    
    for branch in "${branches[@]}"; do
        print_info "🗑️  Deleting branch: $branch"
        if git branch -D "$branch" &>/dev/null; then
            ((deleted++))
        else
            print_warning "Failed to delete branch: $branch"
            ((failed++))
        fi
    done
    
    if [ "$deleted" -gt 0 ]; then
        print_success "Deleted $deleted branch(es)"
    fi
    if [ "$failed" -gt 0 ]; then
        print_warning "$failed branch(es) could not be deleted"
    fi
    
    return $failed
}

# Function to stash changes
stash_changes() {
    local message="${1:-Auto-stash}"
    print_info "💾 Stashing changes..."
    if ! git stash push -m "$message"; then
        error_exit "Failed to stash changes"
    fi
    return 0
}

# Function to restore stashed changes
restore_stash() {
    print_info "📤 Restoring changes..."
    if ! git stash pop; then
        error_exit "Failed to restore changes. Your changes are preserved in the stash"
    fi
}

# Function to rebase current branch
# Args: current_branch [base_branch]
rebase_branch() {
    local current_branch="$1"
    local base_branch="${2:-develop}"
    
    if [ "$current_branch" = "$base_branch" ]; then
        print_info "📥 Updating $base_branch branch..."
        if ! git pull --rebase; then
            error_exit "Failed to update $base_branch branch"
        fi
    else
        print_info "📥 Rebasing from $base_branch..."
        if ! git pull origin "$base_branch" --rebase; then
            error_exit "Failed to rebase from $base_branch"
        fi
    fi
}
