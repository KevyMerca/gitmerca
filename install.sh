#!/bin/bash

# Source core utilities using relative path from script location
source "$(dirname "${BASH_SOURCE[0]}")/src/utils/core-utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/src/utils/version.sh"

# Define variables
TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"
COMMANDS_DIR="src/commands"
UTILS_DIR="src/utils"
BACKUP_DIR="$TARGET_DIR/.backup/$(date +%Y%m%d_%H%M%S)"

# Cleanup function for failed installation
cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Installation failed, cleaning up..."
        rm -rf "$TARGET_DIR"
        error_exit "Installation aborted"
    fi
}

# Backup function
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/" || print_error "Failed to backup $file"
    fi
}

# Copy file with backup
copy_file() {
    local src="$1"
    local dest="$2"
    local make_executable="$3"

    if [ -f "$dest" ]; then
        backup_file "$dest"
    fi
    
    cp "$src" "$dest" || {
        print_error "Failed to copy $src to $dest"
        return 1
    }
    
    if [ "$make_executable" = "true" ]; then
        chmod +x "$dest" || {
            print_error "Failed to make $dest executable"
            return 1
        }
    fi
}

# Create directory structure
create_dirs() {
    mkdir -p "$TARGET_DIR/$COMMANDS_DIR" "$TARGET_DIR/$UTILS_DIR" || {
        print_error "Failed to create directories"
        return 1
    }
}

# Copy essential files
copy_files() {
    # Copy package.json
    copy_file "package.json" "$TARGET_DIR/package.json" || return 1

    # Copy command files
    print_header "Installing commands..."
    for file in "$COMMANDS_DIR"/*; do
        if [ -f "$file" ]; then
            dest="$TARGET_DIR/$COMMANDS_DIR/$(basename "$file")"
            echo "Installing: $(basename "$file")"
            # Copy and adjust utility paths
            sed "s|source \"\\$(dirname \"\${BASH_SOURCE\\[0\\]}\")/../utils|source \"$TARGET_DIR/src/utils|g" "$file" > "$dest"
            chmod +x "$dest" || return 1
        fi
    done

    # Copy utility files
    print_header "Installing utilities..."
    for file in "$UTILS_DIR"/*; do
        if [ -f "$file" ]; then
            dest="$TARGET_DIR/$UTILS_DIR/$(basename "$file")"
            echo "Installing: $(basename "$file")"
            # Copy and adjust source paths
            cp "$file" "$dest" || return 1
        fi
    done
}

# Install man pages
install_man_pages() {
    # Generate man pages
    chmod +x scripts/generate-manpages.sh
    if ! ./scripts/generate-manpages.sh; then
        error_exit "Failed to generate man pages"
    fi
    
    # Determine man page location based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS uses /usr/local/share/man
        MAN_INSTALL_DIR="/usr/local/share/man/man1"
    else
        # Linux typically uses /usr/local/man
        MAN_INSTALL_DIR="/usr/local/man/man1"
    fi
    
    # Create man directory with proper permissions
    echo "Creating man directory: $MAN_INSTALL_DIR"
    sudo mkdir -p "$MAN_INSTALL_DIR"
    sudo chmod 755 "$MAN_INSTALL_DIR"
    
    # Copy and set permissions for man pages
    for manpage in man/man1/*.1.gz; do
        if [ -f "$manpage" ]; then
            echo "Installing: $(basename "$manpage")"
            sudo cp "$manpage" "$MAN_INSTALL_DIR/"
            sudo chmod 644 "$MAN_INSTALL_DIR/$(basename "$manpage")"
        fi
    done
    
    print_success "Man pages installed successfully"
    return 0
}

# Update PATH in .zshrc
update_zshrc() {
    if [ ! -f "$ZSHRC" ]; then
        print_error ".zshrc not found. Please add the following to your shell configuration:"
        echo "export PATH=\"\$PATH:$TARGET_DIR/$COMMANDS_DIR\""
        return 1
    fi

    backup_file "$ZSHRC"
    
    # Create a temporary file
    TEMP_RC=$(mktemp) || error_exit "Failed to create temporary file"
    
    # Remove any existing Gitmerca PATH entries
    sed '/gitmerca.*commands/d' "$ZSHRC" > "$TEMP_RC"
    
    # Add the new PATH entry
    {
        echo ""
        echo "# Gitmerca: Custom git commands for mercateam contributors"
        echo "export PATH=\"$TARGET_DIR/$COMMANDS_DIR:\$PATH\""
    } >> "$TEMP_RC" || error_exit "Failed to update .zshrc"
    
    # Replace original file
    mv "$TEMP_RC" "$ZSHRC" || error_exit "Failed to update .zshrc"
    chmod 644 "$ZSHRC"
    print_success "PATH updated in .zshrc"
    
    # Source the updated .zshrc
    source "$ZSHRC" || {
        print_error "Failed to source .zshrc"
        echo "Please run: source $ZSHRC"
        return 1
    }
    
    return 0
}

# Main installation function
main() {
    local version=$VERSION
    print_header "Installing Gitmerca v${version}..."

    # Validate environment
    command -v git >/dev/null 2>&1 || {
        print_error "Git is not installed. Please install Git first."
        exit 1
    }

    # Set up error handling
    trap cleanup EXIT

    # Create directory structure
    echo "Creating directories..."
    create_dirs || cleanup

    # Copy all files
    echo "Copying essential files..."
    copy_files || cleanup

    # Install man pages
    echo "Installing man pages..."
    install_man_pages || cleanup

    # Update PATH in .zshrc
    echo "Updating PATH in .zshrc..."
    update_zshrc || cleanup

    # Installation successful, remove trap
    trap - EXIT

    print_success "Installation complete! 🎉"
    echo "Gitmerca commands are now available. Run 'git wrapup --help' to get started."
}

# Run the main installation
main