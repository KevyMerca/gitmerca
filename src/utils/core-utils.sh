#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_info() { echo -e "${YELLOW}$1${NC}"; }
print_success() { echo -e "${GREEN}✨ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}" >&2; }
print_header() { echo -e "${BLUE}$1${NC}"; }

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
