#!/bin/zsh

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define variables
TARGET_DIR="$HOME/gitmerca"
ZSHRC="$HOME/.zshrc"
COMMANDS_DIR="src/commands"
UTILS_DIR="src/utils"

# Print with color
print_info() { echo -e "${BLUE}INFO:${NC} $1"; }
print_success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
print_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate environment
if ! command_exists git; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

print_info "Installing Gitmerca..."

# Create the target directories
print_info "Creating directories..."
mkdir -p "$TARGET_DIR/commands"
mkdir -p "$TARGET_DIR/utils"

# Copy command files
print_info "Installing commands..."
for file in "$COMMANDS_DIR"/*; do
    if [ -f "$file" ]; then
        if [ -e "$TARGET_DIR/commands/$(basename "$file")" ]; then
            print_info "Updating command: $(basename "$file")"
        else
            print_info "Installing command: $(basename "$file")"
        fi
        cp "$file" "$TARGET_DIR/commands/" || {
            print_error "Failed to copy command file: $file"
            exit 1
        }
        chmod +x "$TARGET_DIR/commands/$(basename "$file")" || {
            print_error "Failed to make command executable: $file"
            exit 1
        }
    fi
done

# Copy utility files
print_info "Installing utilities..."
for file in "$UTILS_DIR"/*; do
    if [ -f "$file" ]; then
        if [ -e "$TARGET_DIR/utils/$(basename "$file")" ]; then
            print_info "Updating utility: $(basename "$file")"
        else
            print_info "Installing utility: $(basename "$file")"
        fi
        cp "$file" "$TARGET_DIR/utils/" || {
            print_error "Failed to copy utility file: $file"
            exit 1
        }
    fi
done

# Update PATH in .zshrc
if [ -f "$ZSHRC" ]; then
    if grep -q "$TARGET_DIR/commands" "$ZSHRC"; then
        print_info "PATH is already configured in .zshrc"
    else
        print_info "Updating PATH in .zshrc..."
        {
            echo ""
            echo "# Gitmerca: Custom git commands for mercateam contributors"
            echo "export PATH=\"\$PATH:$TARGET_DIR/commands\""
        } >> "$ZSHRC" || {
            print_error "Failed to update .zshrc"
            exit 1
        }
        print_success "PATH updated in .zshrc"
    fi
    
    # Source the .zshrc to apply changes
    print_info "Applying changes..."
    source "$ZSHRC" || {
        print_error "Failed to source .zshrc"
        print_info "Please run: source $ZSHRC"
    }
else
    print_error ".zshrc not found. Please add the following to your shell configuration:"
    echo "export PATH=\"\$PATH:$TARGET_DIR/commands\""
fi

print_success "Installation complete! 🎉"
print_info "Gitmerca commands are now available. Run 'git wrapup --help' to get started."