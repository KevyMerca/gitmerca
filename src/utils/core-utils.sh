#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Support NO_COLOR standard (https://no-color.org/)
if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]]; then
    GREEN='' YELLOW='' RED='' BLUE='' GRAY='' NC=''
fi

# Print with color
print_info() { echo -e "${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✨ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}" >&2; }
print_header() { echo -e "${BLUE}$1${NC}"; }
print_dry_run() { echo -e "${GRAY}[DRY-RUN] $1${NC}"; }

# Error handler function
error_exit() {
    print_error "Error: $1"
    exit 1
}

# Function to confirm with user
confirm() {
    local message="$1"
    echo -en "${YELLOW}$message [y/N]: ${NC}"
    read -r response
    [[ "$response" =~ ^[yY](es)?$ ]]
}

# =============================================================================
# Configuration File Support
# =============================================================================

# Default configuration values
GITMERCA_DEFAULT_BASE_BRANCH="develop"
GITMERCA_SKIP_CHANGESET="false"
GITMERCA_AUTO_OPEN_PR="true"

# Configuration file locations (in order of priority)
GITMERCA_CONFIG_FILES=(
    ".gitmercaconfig"           # Project-local config
    "$HOME/.gitmercaconfig"     # User config
    "$HOME/.config/gitmerca/config"  # XDG config
)

# Load configuration from file
load_config() {
    local config_file=""
    
    # Find first existing config file
    for file in "${GITMERCA_CONFIG_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            config_file="$file"
            break
        fi
    done
    
    # No config file found, use defaults
    if [[ -z "$config_file" ]]; then
        return 0
    fi
    
    # Parse config file (simple key=value format)
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Remove quotes from value
        value="${value#\"}"
        value="${value%\"}"
        value="${value#\'}"
        value="${value%\'}"
        
        case "$key" in
            default_base_branch|base_branch)
                GITMERCA_DEFAULT_BASE_BRANCH="$value"
                ;;
            skip_changeset|no_changeset)
                GITMERCA_SKIP_CHANGESET="$value"
                ;;
            auto_open_pr|open_pr)
                GITMERCA_AUTO_OPEN_PR="$value"
                ;;
        esac
    done < "$config_file"
}

# Get config value with fallback
get_config() {
    local key="$1"
    local default="$2"
    
    case "$key" in
        base_branch)
            echo "${GITMERCA_DEFAULT_BASE_BRANCH:-$default}"
            ;;
        skip_changeset)
            echo "${GITMERCA_SKIP_CHANGESET:-$default}"
            ;;
        auto_open_pr)
            echo "${GITMERCA_AUTO_OPEN_PR:-$default}"
            ;;
        *)
            echo "$default"
            ;;
    esac
}

# Load config on source
load_config
