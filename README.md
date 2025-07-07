# Gitmerca 🛠️

Enhance your Git workflow with Gitmerca - a set of custom Git commands specifically designed for contributors to the mercateam repository! These tools automate common operations and streamline the development process according to mercateam's workflow patterns.

## 🚀 Quick Start

Run the installation script to get started:

```sh
./install.sh
```

### What the installer does:

1. 📁 Creates a `gitmerca` directory in your home folder
2. 📋 Copies the custom Git commands and utilities
3. 🔄 Adds the commands to your `PATH` in `.zshrc`
4. ✨ Reloads your shell environment

### Uninstalling

To remove Gitmerca from your system, you have two options:

```sh
# For current installations:
./uninstall.sh

# For legacy installations (if you previously used my-git-custom-commands):
./legacy_uninstall.sh
```

Both uninstall scripts will:
1. 🗑️ Remove the installation directory
2. 🧹 Clean up PATH entries in `.zshrc`
3. 💾 Create a backup of your `.zshrc` before making changes
4. ✨ Provide clear feedback about the removal process

Note: After uninstalling, remember to run `source ~/.zshrc` to update your current shell.

## 🎯 Available Commands

| Command       | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `git wrapup`  | Automates the mercateam PR workflow: stashes changes, rebases from `develop`, runs `pnpm changeset`, commits with your message, pushes changes, and opens a PR in your browser. |
| `git reform`  | Streamlines branch management according to mercateam patterns: stashes changes, rebases from `develop`, optionally checks out or creates a target branch, and restores your changes. |
| `git cleanup` | Keeps your local branches tidy by removing all local branches except `develop` (mercateam's main integration branch). |

## 🏗️ Project Structure

```
├── src/
│   ├── commands/           # Git command implementations
│   │   ├── git-cleanup    # Remove unused branches
│   │   ├── git-reform     # Branch management and rebasing
│   │   └── git-wrapup     # Automated PR workflow
│   └── utils/             # Shared utilities
│       └── git-utils      # Common Git operations
├── tests/                 # Test files
│   ├── git-cleanup_test.sh
│   ├── git-reform_test.sh
│   ├── git-utils_test.sh
│   └── git-wrapup_test.sh
├── lib/                   # External dependencies and utilities
│   └── test/             # Testing infrastructure
│       ├── bashunit      # Testing framework
│       └── test_helpers.sh # Shared test utilities
├── install.sh            # Installation script
├── uninstall.sh         # Clean removal script
├── legacy_uninstall.sh  # Legacy installation cleanup
└── run_tests.sh         # Test runner
```

## 🧪 Testing

We use a custom testing infrastructure built on top of the `bashunit` framework. The testing setup includes mock functions, assertions, and utilities to make testing Git commands easier and more reliable.

### Running Tests

To run the complete test suite:

```sh
./run_tests.sh
```

You'll see output like this:

```
=== Running test suite ===

>>> Running example_test.sh...
[PASS] example_test.sh
...test details...

>>> Running git-reform_test.sh...
[PASS] git-reform_test.sh
...test details...

=== Test suite complete ===
All tests passed!
```

Note: You may occasionally see a message about "BASHUNIT_GIT_REPO: readonly variable" - this is a benign warning from bashunit's internals and can be safely ignored.

To run specific test files:

```sh
./tests/git-wrapup_test.sh
./tests/git-reform_test.sh
./tests/git-utils_test.sh
```

### Test Structure

Each test file follows a consistent pattern:

```bash
# Source test helpers (provides paths and utilities)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Default mock values and state
DEFAULT_BRANCH="feature/test-branch"

# Mock functions (e.g., git command mocks)
function git() {
    # Mock implementation
}

# Setup and teardown
function setUp() {
    reset_mocks
}

function tearDown() {
    # Clean up any test state
    unset -f git
}

# Test cases
function test_feature() {
    # Test implementation
    assert_contains "Expected output" "$actual_output"
}
```

### Testing Utilities

The `test_helpers.sh` provides several useful functions:

- **Path Resolution**
  - `PROJECT_ROOT`: Root directory of the project
  - `COMMANDS_DIR`: Location of Git commands
  - `UTILS_DIR`: Location of utility functions

- **Assertions**
  - `assert_contains`: Check if output contains expected string
  - `assert_exact`: Check for exact string match
  - `assert_success`: Verify command success
  - `assert_failure`: Verify command failure

- **Output Formatting**
  - Colored output for better readability
  - Clear error messages
  - Test progress indicators

## 💡 Tips

- These commands are specifically designed for the mercateam repository workflow, which uses `develop` as the main integration branch
- `git wrapup` is optimized for mercateam's PR process, automatically running `pnpm changeset` and opening PRs in the correct format
- All commands include safety checks to prevent operations that would conflict with mercateam's workflow
- The tools assume you're working with the mercateam repository structure and conventions

## 🚧 Development

To add new features or modify existing ones:

1. Create or modify command files in `src/commands`
2. Add shared utilities to `src/utils` if needed
3. Write tests in `tests` directory following the established pattern
4. Use provided test helpers and mock functions
5. Run the test suite to verify changes
6. Update documentation as needed

### Installation Scripts

The project includes several installation-related scripts:

- `install.sh`: Main installation script with colored output and error handling
- `uninstall.sh`: Clean removal of current installations
- `legacy_uninstall.sh`: Handles removal of both old and new installation formats

When modifying these scripts, ensure they:
- Handle errors gracefully with helpful messages
- Create backups before making destructive changes
- Provide clear feedback about their progress
- Clean up any temporary files
- Maintain idempotency (can be run multiple times safely)

## 🤝 Contributing

Feel free to open issues or submit pull requests in the Gitmerca repository if you have suggestions for improving the mercateam development workflow! Please ensure:

1. Follow the existing code structure
2. Add comprehensive tests for new functionality
3. Update documentation, especially regarding mercateam-specific workflows
4. Ensure all tests pass using `./run_tests.sh`
5. Consider the impact on the broader mercateam development process

## 📝 License

This project is open source and available under the MIT License.