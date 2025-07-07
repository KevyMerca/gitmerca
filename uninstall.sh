#!/bin/bash

# Source utilities using relative path from script location
source "$(dirname "${BASH_SOURCE[0]}")/src/utils/core-utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/src/utils/version.sh"

# Define variables
TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"
BACKUP_SUFFIX=".gitmerca.backup.$(date +%Y%m%d_%H%M%S)"

# Remove gitmerca directory
remove_gitmerca_dir() {
    if [ -d "$TARGET_DIR" ]; then
        echo "Removing Gitmerca directory..."
        rm -rf "$TARGET_DIR" || error_exit "Failed to remove directory: $TARGET_DIR"
        print_success "Removed Gitmerca directory"
    else
        echo "Gitmerca directory not found (already removed)"
    fi
    return 0
}

# Clean up .zshrc
cleanup_zshrc() {
    if [ ! -f "$ZSHRC" ]; then
        echo ".zshrc not found (no cleanup needed)"
        return 0
    fi

    echo "Cleaning up .zshrc..."
    
    # Backup original .zshrc
    cp "$ZSHRC" "$ZSHRC$BACKUP_SUFFIX" || error_exit "Failed to create .zshrc backup"
    echo "Created backup: $ZSHRC$BACKUP_SUFFIX"
    
    # Create a temporary file
    TEMP_RC=$(mktemp) || error_exit "Failed to create temporary file"
    
    # Remove Gitmerca comments and PATH entries
    awk '!/^# Gitmerca:/ && !/'$(echo "$TARGET_DIR" | sed 's/\//\\\//g')'/' "$ZSHRC" > "$TEMP_RC" || {
        rm -f "$TEMP_RC"
        error_exit "Failed to update .zshrc"
    }
    
    # Remove any resulting double blank lines
    awk 'NR==1{print} NR>1{if(!(/^[[:space:]]*$/ && prev~/^[[:space:]]*$/)){print}} {prev=$0}' "$TEMP_RC" > "$TEMP_RC.clean" || {
        rm -f "$TEMP_RC" "$TEMP_RC.clean"
        error_exit "Failed to clean up blank lines"
    }
    
    # Replace .zshrc with cleaned version
    mv "$TEMP_RC.clean" "$ZSHRC" || {
        rm -f "$TEMP_RC" "$TEMP_RC.clean"
        error_exit "Failed to update .zshrc. Your original .zshrc has been preserved as $ZSHRC$BACKUP_SUFFIX"
    }
    
    rm -f "$TEMP_RC"
    chmod 644 "$ZSHRC"
    print_success "Cleaned up .zshrc"
    return 0
}

# Remove man pages
remove_man_pages() {
    print_header "Removing man pages..."
    
    # Determine man page location based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS uses /usr/local/share/man
        MAN_DIR="/usr/local/share/man/man1"
    else
        # Linux typically uses /usr/local/man
        MAN_DIR="/usr/local/man/man1"
    fi

    # Check if directory exists
    if [ -d "$MAN_DIR" ]; then
        # List of gitmerca commands
        commands=("cleanup" "reform" "wrapup" "merca")
        
        # Remove man pages for each command
        for cmd in "${commands[@]}"; do
            if [ -f "$MAN_DIR/git-$cmd.1" ] || [ -f "$MAN_DIR/git-$cmd.1.gz" ]; then
                sudo rm -f "$MAN_DIR/git-$cmd.1" "$MAN_DIR/git-$cmd.1.gz"
            fi
        done
        print_success "Removed man pages"
    else
        print_info "Man directory not found (no cleanup needed)"
    fi
    
    return 0
}

# Main uninstallation function
main() {
    local version=$VERSION
    print_header "Uninstalling Gitmerca v${version}..."

    # Remove gitmerca directory
    remove_gitmerca_dir || error_exit "Failed to remove Gitmerca directory"

    # Clean up .zshrc
    cleanup_zshrc || error_exit "Failed to clean up .zshrc"

    # Remove man pages
    remove_man_pages || error_exit "Failed to remove man pages"

    print_success "Gitmerca has been successfully uninstalled! 👋"
    echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
}

# Run the main uninstallation
main
