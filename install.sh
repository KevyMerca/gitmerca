#!/bin/zsh

# Define variables
TARGET_DIR="$HOME/my-git-custom-commands"
ZSHRC="$HOME/.zshrc"
COMMANDS_DIR="src/commands"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the files to the target directory
for file in "$COMMANDS_DIR"/*; do
    if [ -e "$TARGET_DIR/$(basename "$file")" ]; then
        echo "Overwriting file: $(basename "$file")"
    else
        echo "Creating file: $(basename "$file")"
    fi
    cp "$file" "$TARGET_DIR"
done

# Add the target directory to PATH in .zshrc if not already added
if [ -f "$ZSHRC" ]; then
    if grep -q "$TARGET_DIR" "$ZSHRC"; then
        echo "The export PATH line is already present in .zshrc"
    else
        echo "Adding export PATH line to .zshrc"
        {
            echo ""
            echo "# Gitmerca: Adding custom git commands to the path"
            echo "export PATH=\"\$PATH:$TARGET_DIR\""
        } >> "$ZSHRC"
    fi
    # Source the .zshrc to apply changes
    echo "Sourcing .zshrc"
    source "$ZSHRC"
fi

echo "Installation complete."