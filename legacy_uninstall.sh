#!/bin/zsh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define variables for both old and new installations
OLD_TARGET_DIR="$HOME/my-git-custom-commands"
NEW_TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"

# Print with color
print_info() { echo -e "${BLUE}INFO:${NC} $1"; }
print_success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
print_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

print_info "Legacy uninstaller for Gitmerca..."
print_info "This script will remove both old and new installations."

# Remove old gitmerca directory
if [ -d "$OLD_TARGET_DIR" ]; then
    print_info "Removing old installation directory..."
    rm -rf "$OLD_TARGET_DIR" || {
        print_error "Failed to remove directory: $OLD_TARGET_DIR"
        exit 1
    }
    print_success "Removed old installation directory"
else
    print_info "Old installation directory not found (already removed)"
fi

# Remove new gitmerca directory
if [ -d "$NEW_TARGET_DIR" ]; then
    print_info "Removing new installation directory..."
    rm -rf "$NEW_TARGET_DIR" || {
        print_error "Failed to remove directory: $NEW_TARGET_DIR"
        exit 1
    }
    print_success "Removed new installation directory"
else
    print_info "New installation directory not found (already removed)"
fi

# Clean up .zshrc
if [ -f "$ZSHRC" ]; then
    print_info "Cleaning up .zshrc..."
    
    # Create a temporary file
    TEMP_RC=$(mktemp) || {
        print_error "Failed to create temporary file"
        exit 1
    }
    
    # Filter out both old and new Gitmerca lines
    awk '
        !/^# Gitmerca:/ && 
        !/'$(echo "$OLD_TARGET_DIR" | sed 's/\//\\\//g')'/ && 
        !/'$(echo "$NEW_TARGET_DIR" | sed 's/\//\\\//g')'/ &&
        !/^# Git Custom Commands:/' "$ZSHRC" > "$TEMP_RC"
    
    # Remove any resulting double blank lines
    awk 'NR==1{print} NR>1{if(!(/^[[:space:]]*$/ && prev~/^[[:space:]]*$/)){print}} {prev=$0}' "$TEMP_RC" > "$TEMP_RC.clean"
    
    # Backup original .zshrc
    cp "$ZSHRC" "$ZSHRC.gitmerca.backup" || {
        print_error "Failed to create .zshrc backup"
        rm "$TEMP_RC" "$TEMP_RC.clean"
        exit 1
    }
    
    # Replace .zshrc with cleaned version
    mv "$TEMP_RC.clean" "$ZSHRC" || {
        print_error "Failed to update .zshrc"
        print_info "Your original .zshrc has been preserved"
        rm "$TEMP_RC" "$TEMP_RC.clean"
        exit 1
    }
    
    rm "$TEMP_RC"
    print_success "Updated .zshrc"
    print_info "Backup saved as: $ZSHRC.gitmerca.backup"
else
    print_info ".zshrc not found (no cleanup needed)"
fi

print_success "Legacy uninstallation complete! 🧹"
print_info "Both old and new installations have been removed."
print_info "Please run 'source ~/.zshrc' to apply the changes to your current shell"
