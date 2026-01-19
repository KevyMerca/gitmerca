#!/bin/bash

# Source core utilities using relative path from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/src/utils/core-utils.sh"
source "$SCRIPT_DIR/src/utils/version.sh"

# Define variables
TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"
COMMANDS_DIR="src/commands"
UTILS_DIR="src/utils"

# Track if installation succeeded
INSTALL_SUCCESS=false

# Cleanup function for failed installation
cleanup() {
    local exit_code=$?
    
    # Only cleanup on failure, and only once
    if [ "$INSTALL_SUCCESS" = false ] && [ $exit_code -ne 0 ]; then
        print_error "Installation failed."
        echo ""
        echo "If you have an existing installation with permission issues, try:"
        echo "  sudo rm -rf $TARGET_DIR"
        echo "  ./install.sh"
    fi
    
    exit $exit_code
}

# Check and fix existing installation permissions
check_existing_installation() {
    if [ -d "$TARGET_DIR" ]; then
        # Test if we can write to the directory
        if ! touch "$TARGET_DIR/.write_test" 2>/dev/null; then
            print_warning "Existing installation at $TARGET_DIR has permission issues."
            echo ""
            echo "Options:"
            echo "  1. Fix permissions: sudo chown -R \$USER $TARGET_DIR"
            echo "  2. Remove and reinstall: sudo rm -rf $TARGET_DIR && ./install.sh"
            echo ""
            
            if confirm "Attempt to fix permissions automatically?"; then
                sudo chown -R "$USER" "$TARGET_DIR" || {
                    print_error "Failed to fix permissions. Please run manually:"
                    echo "  sudo rm -rf $TARGET_DIR"
                    return 1
                }
                print_success "Permissions fixed!"
            else
                return 1
            fi
        else
            rm -f "$TARGET_DIR/.write_test"
        fi
    fi
    return 0
}

# Backup function (graceful - doesn't fail installation)
backup_file() {
    local file="$1"
    local backup_dir="$TARGET_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$file" ]; then
        if mkdir -p "$backup_dir" 2>/dev/null; then
            cp "$file" "$backup_dir/" 2>/dev/null || print_warning "Could not backup $file"
        fi
    fi
}

# Copy file with optional backup
copy_file() {
    local src="$1"
    local dest="$2"
    local make_executable="${3:-false}"

    # Backup existing file (graceful)
    [ -f "$dest" ] && backup_file "$dest"
    
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

    # Copy uninstall script
    copy_file "uninstall.sh" "$TARGET_DIR/uninstall.sh" "true" || return 1

    # Copy command files
    print_header "Installing commands..."
    for file in "$COMMANDS_DIR"/*; do
        if [ -f "$file" ]; then
            local dest="$TARGET_DIR/$COMMANDS_DIR/$(basename "$file")"
            echo "  Installing: $(basename "$file")"
            # Copy and adjust utility paths
            sed "s|source \"\\$(dirname \"\${BASH_SOURCE\\[0\\]}\")/../utils|source \"$TARGET_DIR/src/utils|g" "$file" > "$dest" || {
                print_error "Failed to install $(basename "$file")"
                return 1
            }
            chmod +x "$dest" || return 1
        fi
    done

    # Copy utility files
    print_header "Installing utilities..."
    for file in "$UTILS_DIR"/*; do
        if [ -f "$file" ]; then
            local dest="$TARGET_DIR/$UTILS_DIR/$(basename "$file")"
            echo "  Installing: $(basename "$file")"
            cp "$file" "$dest" || return 1
        fi
    done
    
    # Copy completion files
    print_header "Installing completions..."
    if [ -d "completions" ]; then
        mkdir -p "$TARGET_DIR/completions" || return 1
        cp -r completions/* "$TARGET_DIR/completions/" || return 1
        print_success "Completions copied to installation directory"
    fi
}

# Install man pages (optional - requires sudo)
install_man_pages() {
    # Check if scripts exist
    if [ ! -f "scripts/generate-manpages.sh" ]; then
        print_warning "Man page generator not found, skipping"
        return 0
    fi

    # Generate man pages
    chmod +x scripts/generate-manpages.sh
    if ! ./scripts/generate-manpages.sh 2>/dev/null; then
        print_warning "Could not generate man pages, skipping"
        return 0
    fi
    
    # Determine man page location based on OS
    local man_dir
    if [[ "$OSTYPE" == "darwin"* ]]; then
        man_dir="/usr/local/share/man/man1"
    else
        man_dir="/usr/local/man/man1"
    fi
    
    # Check if we have man pages to install
    if ! ls man/man1/*.1.gz >/dev/null 2>&1; then
        print_warning "No man pages found, skipping"
        return 0
    fi

    echo "Installing man pages to $man_dir (requires sudo)..."
    
    # Try to install man pages
    if sudo mkdir -p "$man_dir" 2>/dev/null && sudo chmod 755 "$man_dir" 2>/dev/null; then
        for manpage in man/man1/*.1.gz; do
            if [ -f "$manpage" ]; then
                echo "  Installing: $(basename "$manpage")"
                sudo cp "$manpage" "$man_dir/" 2>/dev/null
                sudo chmod 644 "$man_dir/$(basename "$manpage")" 2>/dev/null
            fi
        done
        print_success "Man pages installed"
    else
        print_warning "Could not install man pages (sudo required). Skipping."
        echo "  You can still use 'git <command> --help' for documentation."
    fi
    
    return 0
}

# Update PATH in shell config
update_shell_config() {
    local shell_rc="$ZSHRC"
    
    # Detect shell config file
    if [ ! -f "$shell_rc" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            shell_rc="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            shell_rc="$HOME/.bash_profile"
        else
            print_warning "No shell config found (.zshrc, .bashrc, .bash_profile)"
            echo "Please add this to your shell configuration:"
            echo "  export PATH=\"$TARGET_DIR/$COMMANDS_DIR:\$PATH\""
            return 0
        fi
    fi

    # Check if shell config is owned by user (not root)
    local file_owner
    file_owner=$(stat -f '%Su' "$shell_rc" 2>/dev/null || stat -c '%U' "$shell_rc" 2>/dev/null)
    if [ "$file_owner" = "root" ]; then
        print_warning "$(basename "$shell_rc") is owned by root, not you!"
        echo ""
        echo "This can cause permission issues. Fix with:"
        echo "  sudo chown \$USER $shell_rc"
        echo ""
        if confirm "Fix ownership automatically?"; then
            sudo chown "$USER" "$shell_rc" || {
                print_error "Failed to fix ownership. Run manually:"
                echo "  sudo chown \$USER $shell_rc"
                return 1
            }
            print_success "Ownership fixed!"
        else
            print_warning "Skipping shell config update"
            echo "Add this to your shell configuration manually:"
            echo "  export PATH=\"$TARGET_DIR/$COMMANDS_DIR:\$PATH\""
            return 0
        fi
    fi

    # Backup shell config
    backup_file "$shell_rc"
    
    # Create a temporary file
    local temp_rc
    temp_rc=$(mktemp) || {
        print_error "Failed to create temporary file"
        return 1
    }
    
    # Remove any existing Gitmerca PATH entries
    grep -v 'gitmerca.*commands' "$shell_rc" > "$temp_rc" 2>/dev/null || cp "$shell_rc" "$temp_rc"
    
    # Also remove old comment lines
    grep -v '# Gitmerca:' "$temp_rc" > "${temp_rc}.clean" && mv "${temp_rc}.clean" "$temp_rc"
    
    # Add the new PATH entry
    {
        echo ""
        echo "# Gitmerca: Custom git commands for mercateam contributors"
        echo "export PATH=\"$TARGET_DIR/$COMMANDS_DIR:\$PATH\""
    } >> "$temp_rc"
    
    # Replace original file (use cp + rm instead of mv to handle cross-device issues)
    cp "$temp_rc" "$shell_rc" || {
        print_error "Failed to update $shell_rc"
        rm -f "$temp_rc"
        return 1
    }
    rm -f "$temp_rc"
    
    chmod 644 "$shell_rc"
    print_success "PATH updated in $(basename "$shell_rc")"
    
    return 0
}

# Install shell completions
install_completions() {
    print_header "Installing shell completions..."
    
    local completions_installed=false
    
    # Install Zsh completions
    if command -v zsh >/dev/null 2>&1; then
        local zsh_completion_dir=""
        local oh_my_zsh_dir="$HOME/.oh-my-zsh"
        
        # Check for Oh My Zsh first (needs special handling)
        if [ -d "$oh_my_zsh_dir" ]; then
            # Oh My Zsh: use custom completions directory
            zsh_completion_dir="$oh_my_zsh_dir/completions"
            mkdir -p "$zsh_completion_dir" 2>/dev/null || true
            
            if [ -d "$zsh_completion_dir" ] && [ -w "$zsh_completion_dir" ] 2>/dev/null; then
                for file in "$TARGET_DIR/completions/zsh"/_git-*; do
                    if [ -f "$file" ]; then
                        cp "$file" "$zsh_completion_dir/" 2>/dev/null && {
                            echo "  Installed Zsh completion (Oh My Zsh): $(basename "$file")"
                            completions_installed=true
                        }
                    fi
                done
                if [ "$completions_installed" = true ]; then
                    echo "  Note: Run 'rm ~/.zcompdump* && exec zsh' to reload completions"
                fi
            fi
        fi
        
        # If Oh My Zsh installation didn't work, try other methods
        if [ "$completions_installed" != true ]; then
            # Try to find zsh completion directory
            if [ -d "/usr/local/share/zsh/site-functions" ] && [ -w "/usr/local/share/zsh/site-functions" ] 2>/dev/null; then
                zsh_completion_dir="/usr/local/share/zsh/site-functions"
            elif [ -d "$HOME/.zsh/completions" ] || mkdir -p "$HOME/.zsh/completions" 2>/dev/null; then
                zsh_completion_dir="$HOME/.zsh/completions"
            fi
            
            if [ -n "$zsh_completion_dir" ] && [ -w "$zsh_completion_dir" ] 2>/dev/null; then
                # Copy to system/user directory
                for file in "$TARGET_DIR/completions/zsh"/_git-*; do
                    if [ -f "$file" ]; then
                        cp "$file" "$zsh_completion_dir/" 2>/dev/null && {
                            echo "  Installed Zsh completion: $(basename "$file")"
                            completions_installed=true
                        }
                    fi
                done
            else
                # Add to fpath in .zshrc (must be BEFORE oh-my-zsh.sh if OMZ is present)
                if [ -f "$ZSHRC" ]; then
                    if ! grep -q "gitmerca.*completions" "$ZSHRC" 2>/dev/null; then
                        local temp_rc
                        temp_rc=$(mktemp) || {
                            print_warning "Could not create temp file for .zshrc update"
                            return 0
                        }
                        
                        local completion_block="# Gitmerca: Zsh completions
fpath=(\"$TARGET_DIR/completions/zsh\" \$fpath)"
                        
                        # If Oh My Zsh is present, insert BEFORE oh-my-zsh.sh
                        # Otherwise, add at the end
                        if grep -q "oh-my-zsh.sh\|\. \$ZSH/oh-my-zsh.sh" "$ZSHRC" 2>/dev/null; then
                            # Insert before Oh My Zsh initialization
                            local inserted=false
                            while IFS= read -r line; do
                                if [[ "$line" =~ (source.*oh-my-zsh\.sh|\. \$ZSH/oh-my-zsh\.sh) ]] && [ "$inserted" = false ]; then
                                    echo "$completion_block"
                                    echo ""
                                    inserted=true
                                fi
                                echo "$line"
                            done < "$ZSHRC" > "$temp_rc" 2>/dev/null || cp "$ZSHRC" "$temp_rc"
                        else
                            # Add at the end
                            cp "$ZSHRC" "$temp_rc"
                            {
                                echo ""
                                echo "$completion_block"
                            } >> "$temp_rc"
                        fi
                        
                        cp "$temp_rc" "$ZSHRC" && {
                            rm -f "$temp_rc"
                            echo "  Added Zsh completions to $ZSHRC"
                            if [ -d "$oh_my_zsh_dir" ]; then
                                echo "  Note: Run 'rm ~/.zcompdump* && exec zsh' to reload completions"
                            fi
                            completions_installed=true
                        } || rm -f "$temp_rc"
                    fi
                fi
            fi
        fi
    fi
    
    # Install Bash completions
    if command -v bash >/dev/null 2>&1; then
        local bash_completion_dir="$HOME/.bash_completion.d"
        local bashrc_file=""
        
        # Detect bash config file
        if [ -f "$HOME/.bashrc" ]; then
            bashrc_file="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            bashrc_file="$HOME/.bash_profile"
        fi
        
        if [ -n "$bashrc_file" ]; then
            # Create completion directory
            mkdir -p "$bash_completion_dir" 2>/dev/null || true
            
            # Copy completion files
            for file in "$TARGET_DIR/completions/bash"/git-*; do
                if [ -f "$file" ]; then
                    cp "$file" "$bash_completion_dir/" 2>/dev/null && {
                        echo "  Installed Bash completion: $(basename "$file")"
                        completions_installed=true
                    }
                fi
            done
            
            # Add source line to bashrc if not present
            if [ -n "$bashrc_file" ] && ! grep -q "bash_completion.d.*gitmerca\|gitmerca.*bash_completion" "$bashrc_file" 2>/dev/null; then
                {
                    echo ""
                    echo "# Gitmerca: Bash completions"
                    echo "if [ -d \"$bash_completion_dir\" ]; then"
                    echo "    for file in \"$bash_completion_dir\"/git-*; do"
                    echo "        [ -f \"\$file\" ] && source \"\$file\""
                    echo "    done"
                    echo "fi"
                } >> "$bashrc_file"
                echo "  Added Bash completions to $(basename "$bashrc_file")"
            fi
        fi
    fi
    
    # Install Fish completions
    if command -v fish >/dev/null 2>&1; then
        local fish_completion_dir="$HOME/.config/fish/completions"
        
        mkdir -p "$fish_completion_dir" 2>/dev/null || true
        
        if [ -d "$fish_completion_dir" ]; then
            for file in "$TARGET_DIR/completions/fish"/*.fish; do
                if [ -f "$file" ]; then
                    cp "$file" "$fish_completion_dir/" 2>/dev/null && {
                        echo "  Installed Fish completion: $(basename "$file")"
                        completions_installed=true
                    }
                fi
            done
        fi
    fi
    
    if [ "$completions_installed" = true ]; then
        print_success "Shell completions installed"
        echo "  Reload your shell or open a new terminal to use completions"
    else
        print_warning "No shell completions installed (shells not detected or no write access)"
        echo "  See completions/README.md for manual installation instructions"
    fi
    
    return 0
}

# Main installation function
main() {
    local version="${VERSION:-unknown}"
    print_header "Installing Gitmerca v${version}..."
    echo ""

    # Validate environment
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi

    # Set up error handling
    trap cleanup EXIT

    # Check existing installation
    echo "Checking existing installation..."
    check_existing_installation || exit 1

    # Create directory structure
    echo "Creating directories..."
    create_dirs || exit 1

    # Copy all files
    echo "Copying files..."
    copy_files || exit 1

    # Install man pages (optional)
    echo "Installing man pages..."
    install_man_pages

    # Install shell completions
    install_completions

    # Update PATH in shell config
    echo "Updating shell configuration..."
    update_shell_config || exit 1

    # Mark installation as successful
    INSTALL_SUCCESS=true

    # Remove trap since we succeeded
    trap - EXIT

    echo ""
    print_success "Installation complete! 🎉"
    echo ""
    echo "To start using gitmerca, either:"
    echo "  • Open a new terminal, or"
    echo "  • Run: source ~/.zshrc"
    echo ""
    echo "Then try: git wrapup --help"
}

# Run the main installation
main "$@"
