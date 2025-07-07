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
BACKUP_DIR="$TARGET_DIR/.backup/$(date +%Y%m%d_%H%M%S)"

# Print with color
print_info() { echo -e "${BLUE}INFO:${NC} $1"; }
print_success() { echo -e "${GREEN}SUCCESS:${NC} $1"; }
print_error() { echo -e "${RED}ERROR:${NC} $1" >&2; }

# Cleanup function for failed installation
cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Installation failed, cleaning up..."
        rm -rf "$TARGET_DIR"
        exit 1
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

# Get version from package.json
if command -v node >/dev/null 2>&1; then
    VERSION=$(node -p "require('./package.json').version" 2>/dev/null)
else
    VERSION=$(grep -m 1 '"version":' "package.json" | sed -E 's/.*"version":[[:space:]]*"([^"]+)".*/\1/')
fi
VERSION=${VERSION:-"unknown"}

print_info "Installing Gitmerca v${VERSION}..."

# Set up error handling
trap cleanup EXIT

# Validate environment
command -v git >/dev/null 2>&1 || {
    print_error "Git is not installed. Please install Git first."
    exit 1
}

# Create directory structure
print_info "Creating directories..."
mkdir -p "$TARGET_DIR/$COMMANDS_DIR" "$TARGET_DIR/$UTILS_DIR"

# Copy essential files
print_info "Copying essential files..."
copy_file "package.json" "$TARGET_DIR/package.json"

# Copy command files
print_info "Installing commands..."
for file in "$COMMANDS_DIR"/*; do
    if [ -f "$file" ]; then
        dest="$TARGET_DIR/$COMMANDS_DIR/$(basename "$file")"
        print_info "Installing: $(basename "$file")"
        copy_file "$file" "$dest" "true"
    fi
done

# Copy utility files
print_info "Installing utilities..."
for file in "$UTILS_DIR"/*; do
    if [ -f "$file" ]; then
        dest="$TARGET_DIR/$UTILS_DIR/$(basename "$file")"
        print_info "Installing: $(basename "$file")"
        copy_file "$file" "$dest"
    fi
done

# Update PATH in .zshrc
if [ -f "$ZSHRC" ]; then
    print_info "Updating PATH in .zshrc..."
    backup_file "$ZSHRC"
    
    # Create a temporary file
    TEMP_RC=$(mktemp) || {
        print_error "Failed to create temporary file"
        exit 1
    }
    
    # Remove any existing Gitmerca PATH entries
    sed '/gitmerca.*commands/d' "$ZSHRC" > "$TEMP_RC"
    
    # Add the new PATH entry
    {
        echo ""
        echo "# Gitmerca: Custom git commands for mercateam contributors"
        echo "export PATH=\"$TARGET_DIR/$COMMANDS_DIR:\$PATH\""
    } >> "$TEMP_RC" || {
        print_error "Failed to update .zshrc"
        rm -f "$TEMP_RC"
        exit 1
    }
    
    # Replace original file
    mv "$TEMP_RC" "$ZSHRC" || {
        print_error "Failed to update .zshrc"
        rm -f "$TEMP_RC"
        exit 1
    }
    chmod 644 "$ZSHRC"
    print_success "PATH updated in .zshrc"
    
    print_info "Applying changes..."
    source "$ZSHRC" || {
        print_error "Failed to source .zshrc"
        print_info "Please run: source $ZSHRC"
    }
else
    print_error ".zshrc not found. Please add the following to your shell configuration:"
    echo "export PATH=\"\$PATH:$TARGET_DIR/$COMMANDS_DIR\""
fi

# Installation successful, remove trap
trap - EXIT

print_success "Installation complete! 🎉"
print_info "Gitmerca commands are now available. Run 'git wrapup --help' to get started."