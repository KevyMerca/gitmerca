#!/bin/bash

# Source test helpers
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Source version utilities
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src/utils/version.sh"

# Source the script to test
SCRIPT_PATH="$COMMANDS_DIR/git-merca"

# Default mock values
DEFAULT_VERSION="2.2.0"
DEFAULT_PATH="/Users/test/gitmerca/src/commands"
DEFAULT_LATEST_TAG="v2.2.0"

# Reset mock state
function reset_mocks() {
    MOCK_VERSION="$DEFAULT_VERSION"
    MOCK_PATH="$DEFAULT_PATH"
    MOCK_LATEST_TAG="$DEFAULT_LATEST_TAG"
    MOCK_COMMANDS="git-cleanup\ngit-reform\ngit-wrapup\ngit-merca"
    MOCK_HAS_PNPM=0
    MOCK_HAS_GIT=0
    MOCK_USER_INPUT=""
    MOCK_UNINSTALL_SCRIPT_EXISTS=0
}

# Mock uninstall script functions
function mock_uninstall_script() {
    # Always remove old script first
    rm -f "$PROJECT_ROOT/uninstall.sh"
    
    if [ "$MOCK_UNINSTALL_SCRIPT_EXISTS" = "1" ]; then
        cat > "$PROJECT_ROOT/uninstall.sh" << 'EOF'
#!/bin/bash
if [ "${MOCK_UNINSTALL_FAILS:-0}" = "1" ]; then
    exit 1
fi
exit 0
EOF
        chmod +x "$PROJECT_ROOT/uninstall.sh"
    fi
}

function cleanup_mock_files() {
    rm -f "$PROJECT_ROOT/uninstall.sh"
}

# Mock functions
function git() {
    case "$1" in
        "describe")
            echo "$MOCK_LATEST_TAG"
            ;;
        "fetch")
            return 0
            ;;
        "checkout")
            return 0
            ;;
        "--version")
            echo "git version 2.39.2"
            ;;
        *)
            return 0
            ;;
    esac
}

function command() {
    if [ "$2" = "pnpm" ]; then
        return $MOCK_HAS_PNPM
    elif [ "$2" = "git" ]; then
        return $MOCK_HAS_GIT
    fi
    return 1
}

function ls() {
    if [[ "$*" == *"git-"* ]]; then
        echo -e "$MOCK_COMMANDS"
        return 0
    fi
    /bin/ls "$@"
}

# Setup and teardown
function setUp() {
    reset_mocks
    cleanup_mock_files
    export HOME="/Users/test"
    export PATH="$MOCK_PATH:$PATH"
    [ "$MOCK_UNINSTALL_SCRIPT_EXISTS" = "1" ] && mock_uninstall_script
}

function tearDown() {
    cleanup_mock_files
    unset HOME
    unset MOCK_USER_INPUT
    unset MOCK_UNINSTALL_FAILS
    unset MOCK_UNINSTALL_SCRIPT_EXISTS
}

# Test cases
function test_version_flag() {
    local output
    output=$("$SCRIPT_PATH" --version 2>&1)
    assert_contains "Gitmerca" "$output"
    assert_contains "$MOCK_VERSION" "$output"
}

function test_help_shows_all_commands() {
    local output
    output=$("$SCRIPT_PATH" --help 2>&1)
    assert_contains "update" "$output"
    assert_contains "uninstall" "$output"
    assert_contains "doctor" "$output"
    assert_contains "list" "$output"
}

function test_unknown_command() {
    local output
    output=$("$SCRIPT_PATH" invalid-command 2>&1) || true
    assert_contains "Unknown command: invalid-command" "$output"
}

function test_doctor_checks_dependencies() {
    local output
    output=$("$SCRIPT_PATH" doctor 2>&1)
    assert_contains "Running health checks" "$output"
    assert_contains "Git is installed" "$output"
    assert_contains "Available commands" "$output"
}

function test_doctor_missing_pnpm() {
    MOCK_HAS_PNPM=1
    local output
    output=$("$SCRIPT_PATH" doctor 2>&1)
    assert_contains "pnpm is not installed" "$output"
}

function test_update_current_version() {
    MOCK_LATEST_TAG="v$MOCK_VERSION"
    local output
    output=$("$SCRIPT_PATH" update 2>&1)
    assert_contains "You're already on the latest version" "$output"
}

function test_update_new_version() {
    local output
    output=$("$SCRIPT_PATH" update 2>&1)
    assert_contains "Updating from $MOCK_VERSION to $MOCK_LATEST_TAG" "$output"
}

function test_list_shows_all_commands() {
    local output
    output=$("$SCRIPT_PATH" list 2>&1)
    assert_contains "Core Commands:" "$output"
    assert_contains "Meta Commands:" "$output"
    assert_contains "cleanup" "$output"
    assert_contains "reform" "$output"
    assert_contains "wrapup" "$output"
}

function test_uninstall_uses_script() {
    # This is a bit tricky to test as it executes another script
    # For now, we just verify it attempts to use the uninstall script
    local output
    output=$("$SCRIPT_PATH" uninstall 2>&1) || true
    assert_contains "uninstall.sh" "$output"
}

function test_config_placeholder() {
    local output
    output=$("$SCRIPT_PATH" config 2>&1)
    assert_contains "Configuration:" "$output"
    assert_contains "Coming soon" "$output"
}

function test_uninstall_confirm_yes() {
    export MOCK_UNINSTALL_SCRIPT_EXISTS=1
    export MOCK_USER_INPUT="y"
    export MOCK_UNINSTALL_FAILS=0
    export TESTING=1
    
    local output
    output=$(TESTING=1 "$SCRIPT_PATH" uninstall 2>&1) || true
    
    # Check the output contains expected messages
    assert_contains "Preparing to uninstall Gitmerca" "$output"
    assert_contains "Are you sure" "$output"
    assert_contains "Uninstalling Gitmerca" "$output"
    assert_contains "successfully uninstalled" "$output"
}

function test_uninstall_confirm_no() {
    export MOCK_UNINSTALL_SCRIPT_EXISTS=1
    export MOCK_USER_INPUT="n"
    export TESTING=1
    
    local output
    output=$(TESTING=1 "$SCRIPT_PATH" uninstall 2>&1) || true
    assert_contains "Uninstallation cancelled" "$output"
}

function test_uninstall_missing_script() {
    export MOCK_UNINSTALL_SCRIPT_EXISTS=0
    export TESTING=1
    
    local output
    output=$(TESTING=1 "$SCRIPT_PATH" uninstall 2>&1) || true
    assert_contains "Uninstall script not found" "$output"
    assert_contains "Try running: rm -rf" "$output"
}

function test_uninstall_script_fails() {
    export MOCK_UNINSTALL_SCRIPT_EXISTS=1
    export MOCK_USER_INPUT="y"
    export MOCK_UNINSTALL_FAILS=1
    export TESTING=1
    
    local output
    output=$(TESTING=1 "$SCRIPT_PATH" uninstall 2>&1) || true
    assert_contains "Failed to run uninstall script" "$output"
    assert_contains "Try manual removal" "$output"
}
