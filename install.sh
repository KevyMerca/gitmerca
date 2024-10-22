#!/bin/bash

# Define variables
TARGET_DIR="$HOME/my-git-custom-commands"
ZSHRC="$HOME/.zshrc"
COMMANDS_DIR="src/commands"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the files to the target directory
cp "$COMMANDS_DIR"/* "$TARGET_DIR"

# Add the target directory to PATH in .zshrc if not already added
if [ -f "$ZSHRC" ]; then
    if ! grep -q "$TARGET_DIR" "$ZSHRC"; then
        echo "export PATH=\"\$PATH:$TARGET_DIR\"" >> "$ZSHRC"
    fi
    # Source the .zshrc to apply changes
    source "$ZSHRC"
fi

echo "Installation complete."