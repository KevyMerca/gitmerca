# Gitmerca 🛠️

Enhance your Git workflow with Gitmerca (v2.2.1) - a set of custom Git commands specifically designed for contributors to the mercateam repository! These tools automate common operations and streamline the development process according to mercateam's workflow patterns.

For a look at what's coming next, check out our [ROADMAP.md](ROADMAP.md) - we've got exciting features planned! 🗺️

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

### git wrapup

Automates the mercateam PR workflow with a single command.

```sh
git wrapup [options] <commit-message>

Options:
  -b, --branch <name>     Create or switch to branch before changes
                          (allows running from develop branch)
  -n, --no-changeset      Skip running pnpm changeset
  -v, --version           Show version information
  -h, --help              Show help message
```

Features:
- 📦 Stages all changes
- 📝 Runs pnpm changeset (skip with `-n`)
- 💾 Commits with your message
- 🚀 Pushes changes and opens PR
- 🛡️ Protects `develop` and `main` branches

Examples:
```sh
git wrapup "feat: add new feature"
git wrapup -b feature/new-thing "feat: add new feature"
git wrapup -n "chore: quick fix"  # Skip changeset
```

### git reform

Streamlines branch management with flexible base branch support.

```sh
git reform [options] [target-branch]

Options:
  -f, --from <branch>     Base branch to rebase from (default: develop)
  -v, --version           Show version information
  -h, --help              Show help message
```

Features:
- 💾 Preserves your changes (auto-stash)
- 🔄 Rebases from any base branch
- 🌿 Optionally creates/switches branches
- 📦 Restores your changes

Examples:
```sh
git reform                        # Rebase from develop
git reform feature/new            # Rebase and switch to feature/new
git reform -f main                # Rebase from main instead of develop
git reform -f main feature/new    # Rebase from main and switch to branch
```

### git cleanup

Keeps your workspace tidy by removing unnecessary local branches.

```sh
git cleanup [options]

Options:
  -y, --yes              Skip confirmation prompt
  -v, --version          Show version information
  -h, --help             Show help message
```

Features:
- 🔍 Shows branches to be removed
- ⚡ Preserves develop branch
- 🧹 Cleans up local branches
- ✨ Provides clear feedback

All commands include:
- 🎨 Colored output for better visibility
- ❌ Clear error messages
- 🛡️ Git repository validation
- 📋 Detailed progress feedback

## 🔧 Meta Commands

### git merca

Manage and maintain your Gitmerca installation.

```sh
git merca [command] [options]

Commands:
  update              Update gitmerca to the latest version
  uninstall           Remove gitmerca from your system
  doctor              Check installation health and dependencies
  list                Show all available commands
  config              View or edit configuration
  help                Show this help message

Options:
  -v, --version       Show version information
  -h, --help          Show this help message
```

Features:
- 🔄 Easy updates to the latest version
- 🔍 Health checks for installation and dependencies
- 📋 List all available commands
- ⚙️ Configuration management
- 💡 Helpful documentation and usage info

## 🏗️ Project Structure

```
├── src/
│   ├── commands/           # Git command implementations
│   │   ├── git-cleanup     # Remove unused branches
│   │   ├── git-merca       # Meta command for management
│   │   ├── git-reform      # Branch management and rebasing
│   │   └── git-wrapup      # Automated PR workflow
│   └── utils/              # Shared utilities
│       ├── core-utils.sh   # Color output, errors, confirmations
│       ├── git-utils.sh    # Git operations helpers
│       └── version.sh      # Version management
├── tests/                  # Test files
│   ├── git-cleanup_test.sh
│   ├── git-reform_test.sh
│   ├── git-utils_test.sh
│   └── git-wrapup_test.sh
├── lib/                    # External dependencies and utilities
│   └── test/               # Testing infrastructure
│       ├── bashunit        # Testing framework
│       └── test_helpers.sh # Test isolation utilities
├── install.sh              # Installation script
├── uninstall.sh            # Clean removal script
├── legacy_uninstall.sh     # Legacy installation cleanup
└── run_tests.sh            # Test runner
```

## 🧪 Testing

We use the `bashunit` framework with proper test isolation. Each test creates its own temporary git repository to ensure tests don't affect your actual repos.

### Running Tests

To run the complete test suite:

```sh
./run_tests.sh
```

Or run specific test files:

```sh
./lib/test/bashunit tests/git-wrapup_test.sh
./lib/test/bashunit tests/git-reform_test.sh
```

### Test Structure

Each test file follows a consistent pattern:

```bash
# Source test helpers (provides paths and test repo utilities)
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/test/test_helpers.sh"

# Test cases using bashunit assertions
function test_help_option() {
    local output=$("$SCRIPT_PATH" --help 2>&1)
    assert_contains "Usage:" "$output"
}

# Tests with isolated git repos
function test_feature() {
    local test_dir=$(create_test_repo)
    
    local output=$(run_in_test_repo "$test_dir" "$SCRIPT_PATH" 2>&1)
    assert_contains "Expected output" "$output"
    
    cleanup_test_repo "$test_dir"
}
```

### Testing Utilities

The `test_helpers.sh` provides:

- **Path Resolution**: `PROJECT_ROOT`, `COMMANDS_DIR`, `UTILS_DIR`
- **Test Isolation**: `create_test_repo()`, `cleanup_test_repo()`, `run_in_test_repo()`
- **Assertions**: Use bashunit's built-in assertions (`assert_contains`, `assert_equals`, etc.)

## 💡 Tips

- These commands are specifically designed for the mercateam repository workflow
- `develop` is the default base branch, but you can use `-f main` to work with other branches
- `git wrapup -n` is useful for quick fixes that don't need changesets
- All commands validate that you're in a git repository before running
- The tools protect `develop` and `main` branches from direct commits

## 🚧 Development

To add new features or modify existing ones:

1. Create or modify command files in `src/commands`
2. Add shared utilities to `src/utils` if needed
3. Write tests in `tests` directory following the established pattern
4. Run the test suite to verify changes: `./run_tests.sh`
5. Install to test: `./install.sh`
6. Update documentation as needed

See our [ROADMAP.md](ROADMAP.md) for planned features and improvements! 🗺️

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

## 🗺️ Roadmap

We have an exciting roadmap planned for Gitmerca! Here's a quick overview of what's coming:

- 🛠️ **Core Command Improvements**: Dry-run options and better help
- 👩‍💻 **Developer Experience**: CI/CD, automated releases, and enhanced documentation
- 🔧 **Shell Support**: Command completion and multi-shell compatibility
- 🧪 **Testing & Quality**: Integration tests, benchmarks, and quality checks
- 🚀 **Advanced Features**: Enhanced GitHub integration and workflow optimization
- 👥 **Team Features**: Configuration sharing and workflow analytics

Check out [ROADMAP.md](ROADMAP.md) for the complete plan and timeline!

## 📝 License

This project is open source and available under the MIT License.
