#!/bin/bash

# Get absolute paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMMANDS_DIR="$PROJECT_ROOT/src/commands"
UTILS_DIR="$PROJECT_ROOT/src/utils"
TESTS_DIR="$PROJECT_ROOT/tests"
LIB_DIR="$PROJECT_ROOT/lib"

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Export paths
export PROJECT_ROOT COMMANDS_DIR UTILS_DIR TESTS_DIR LIB_DIR

# Test assertion functions
function assert_contains() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$actual' to contain '$expected'}"
    
    if [[ "$actual" == *"$expected"* ]]; then
        echo -e "${GREEN}✅ $message${NC}"
        return 0
    else
        echo -e "${RED}❌ $message${NC}"
        echo -e "${RED}Expected to contain: $expected${NC}"
        echo -e "${RED}Got: $actual${NC}"
        return 1
    fi
}

function assert_exact() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected exact match}"
    
    if [[ "$actual" == "$expected" ]]; then
        echo -e "${GREEN}✅ $message${NC}"
        return 0
    else
        echo -e "${RED}❌ $message${NC}"
        echo -e "${RED}Expected: $expected${NC}"
        echo -e "${RED}Got: $actual${NC}"
        return 1
    fi
}

function assert_success() {
    local message="$1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
        return 0
    else
        echo -e "${RED}❌ $message (Expected success, got failure)${NC}"
        return 1
    fi
}

function assert_failure() {
    local message="$1"
    if [ $? -ne 0 ]; then
        echo -e "${GREEN}✅ $message${NC}"
        return 0
    else
        echo -e "${RED}❌ $message (Expected failure, got success)${NC}"
        return 1
    fi
}
