#!/bin/zsh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define variables
TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"
BACKUP_SUFFIX=".gitmerca.backup.$(date +%Y%m%d_%H%M%S)"

# Print with color
print_info() { echo -e "${BLUE}INFO:${NC} $1"; }
print_success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
print_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

# Get version from package.json
if command -v node >/dev/null 2>&1; then
    VERSION=$(node -p "require('./package.json').version" 2>/dev/null)
else
    VERSION=$(grep -m 1 '"version":' "package.json" | sed 's/[^0-9.]//g')
fi
VERSION=${VERSION:-"unknown"}

print_info "Uninstalling Gitmerca v${VERSION}..."

# Remove gitmerca directory
if [ -d "$TARGET_DIR" ]; then
    print_info "Removing Gitmerca directory..."
    rm -rf "$TARGET_DIR" || {
        print_error "Failed to remove directory: $TARGET_DIR"
        exit 1
    }
    print_success "Removed Gitmerca directory"
else
    print_info "Gitmerca directory not found (already removed)"
fi

# Remove PATH entry from .zshrc
if [ -f "$ZSHRC" ]; then
    print_info "Cleaning up .zshrc..."
    
    # Backup original .zshrc
    cp "$ZSHRC" "$ZSHRC$BACKUP_SUFFIX" || {
        print_error "Failed to create .zshrc backup"
        exit 1
    }
    print_info "Created backup: $ZSHRC$BACKUP_SUFFIX"
    
    # Create a temporary file
    TEMP_RC=$(mktemp) || {
        print_error "Failed to create temporary file"
        exit 1
    }
    
    # Remove Gitmerca comments and PATH entries
    awk '!/^# Gitmerca:/ && !/'$(echo "$TARGET_DIR" | sed 's/\//\\\//g')'/' "$ZSHRC" > "$TEMP_RC" || {
        print_error "Failed to update .zshrc"
        rm -f "$TEMP_RC"
        exit 1
    }
    
    # Remove any resulting double blank lines
    awk 'NR==1{print} NR>1{if(!(/^[[:space:]]*$/ && prev~/^[[:space:]]*$/)){print}} {prev=$0}' "$TEMP_RC" > "$TEMP_RC.clean" || {
        print_error "Failed to clean up blank lines"
        rm -f "$TEMP_RC" "$TEMP_RC.clean"
        exit 1
    }
    
    # Replace .zshrc with cleaned version
    mv "$TEMP_RC.clean" "$ZSHRC" || {
        print_error "Failed to update .zshrc"
        print_info "Your original .zshrc has been preserved as $ZSHRC$BACKUP_SUFFIX"
        rm -f "$TEMP_RC" "$TEMP_RC.clean"
        exit 1
    }
    
    rm -f "$TEMP_RC"
    chmod 644 "$ZSHRC"
    print_success "Cleaned up .zshrc"
else
    print_info ".zshrc not found (no cleanup needed)"
fi
print_success "Gitmerca has been successfully uninstalled! 👋"
print_info "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
