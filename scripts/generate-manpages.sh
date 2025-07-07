#!/bin/bash

# Source utilities using relative path from script location
source "$(dirname "${BASH_SOURCE[0]}")/../src/utils/core-utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../src/utils/version.sh"

COMMANDS_DIR="src/commands"
MAN_DIR="man/man1"
DATE=$(date "+%B %Y")

# Ensure man directory exists
mkdir -p "$MAN_DIR"

# Get list of all commands
COMMANDS=$(find "$COMMANDS_DIR" -type f -name "git-*" -perm -u+x)

# Function to get command name without git- prefix
get_command_name() {
    basename "$1" | sed 's/^git-//'
}

# Function to extract sections from help output
extract_section() {
    local help_output="$1"
    local start_pattern="$2"
    local end_pattern="$3"
    
    echo "$help_output" | awk -v start="$start_pattern" -v end="$end_pattern" '
        $0 ~ start {p=1;next}
        $0 ~ end {p=0}
        p'
}

# Function to generate man page content
generate_manpage() {
    local cmd="$1"
    local cmd_name=$(get_command_name "$cmd")
    local cmd_name_upper=$(echo "$cmd_name" | tr '[:lower:]' '[:upper:]')
    local help_output=$("$cmd" --help 2>&1)
    local manfile="$MAN_DIR/git-$cmd_name.1"
    
    # Extract sections using awk for more reliable parsing
    local description=$(extract_section "$help_output" "^Description:" "^Options:")
    local options=$(extract_section "$help_output" "^Options:" "^Arguments:")
    local arguments=$(extract_section "$help_output" "^Arguments:" "^Examples:")
    local examples=$(extract_section "$help_output" "^Examples:" "^$")
    
    # Get synopsis from Usage line
    local synopsis=$(echo "$help_output" | grep "^Usage:" | sed 's/^Usage: //')
    
    # Get short description (first line after Description:)
    local short_desc=$(echo "$description" | sed -n '1p' | sed 's/^[[:space:]]*//')
    
    # Create man page
    cat << EOF > "$manfile"
.TH "GIT-$cmd_name_upper" "1" "$DATE" "Git Merca $VERSION" "Git Manual"
.SH NAME
git-$cmd_name \\- $short_desc
.SH SYNOPSIS
$synopsis
.SH DESCRIPTION
$(echo "$description" | sed 's/^/.PP /')
.SH OPTIONS
$(echo "$options" | sed 's/^[[:space:]]*//' | sed 's/^/.TP\n/')
.SH SEE ALSO
git-cleanup(1), git-reform(1), git-wrapup(1), git-merca(1)
.SH AUTHOR
Git Merca Team
.SH REPORTING BUGS
Report bugs to: https://github.com/kevymbappe/gitmerca/issues
.SH COPYRIGHT
Copyright © 2023 Git Merca Team. License MIT
EOF

    # Compress man page
    if [ -s "$manfile" ]; then
        gzip -f "$manfile"
        print_success "Generated man page for git-$cmd_name"
    else
        print_error "Failed to generate man page for git-$cmd_name"
        return 1
    fi
}

# Generate man pages for each command
print_header "Generating man pages..."
for cmd in $COMMANDS; do
    generate_manpage "$cmd" || error_exit "Man page generation failed"
done
print_success "Man page generation complete!"
