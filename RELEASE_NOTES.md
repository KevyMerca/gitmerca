# Gitmerca Release Notes 📝

## Version 2.1.0: Enhanced CLI & User Experience 🎨

This release brings significant improvements to the command-line interface and user experience across all commands.

### Command Line Enhancements 🛠️

All commands now feature improved CLI capabilities:

#### git wrapup
- ✨ NEW: `-b/--branch` option to create/switch branches before changes
- 🚀 Now supports starting from develop branch when using branch option
- 📦 Improved handling of untracked files in stash

#### git reform
- ✨ NEW: `-f/--force` option to skip confirmation prompts
- 🎨 Enhanced branch switching feedback
- 🛡️ Better error handling and state recovery

#### git cleanup
- ✨ NEW: `-y/--yes` option to skip confirmation
- 📊 Added branch count and improved listing
- 🔒 Better safety checks

### Global Improvements 🌟

- 🎨 Added colored output across all commands
- 💡 Added help (`-h/--help`) option to all commands
- 🛡️ Enhanced error handling and user feedback
- 📝 Improved progress indicators with emojis
- 📋 Better documentation and usage examples

### Documentation Updates 📚

- 📖 Updated README with detailed command options
- 🔍 Added clear examples for each command
- 🎯 Enhanced feature descriptions
- 🗺️ Added cross-references to roadmap

### Upgrading to 2.1.0 ⬆️

To upgrade:

1. Update your local copy:
   ```sh
   git pull origin main
   ```

2. Reinstall gitmerca:
   ```sh
   ./install.sh
   ```

All changes are backward compatible - existing workflows will continue to work as before, with new options available when needed.

# Gitmerca v2.0.0-beta.1: First Major Revision 🧪

This is the beta release of Gitmerca v2.0.0, introducing significant changes from the previous unversioned state ("v1"). We're releasing this as a beta to gather feedback from mercateam members and ensure a smooth transition to the new structure.

## Beta Testing Goals 🎯
We're particularly looking for feedback on:
1. Migration process from old installation
2. New installation experience
3. Daily workflow improvements
4. Edge cases in different environments

Please report any issues or suggestions in the GitHub repository.

## Why v2.0.0? 🤔
The previous unversioned state (informally "v1") used `~/my-git-custom-commands`. This release includes breaking changes in installation and structure, warranting a major version bump to v2.0.0.

## What's New ✨
- **Installation System**
  - New home: `~/gitmerca` directory (previously `~/my-git-custom-commands`)
  - Colored output and better error handling
  - Proper version tracking via package.json
  - Safe uninstallation support

- **Commands & Utils**
  - Centralized utility functions
  - Shared version management
  - Better PATH handling
  - Improved safety checks

- **Testing Infrastructure**
  - Enhanced test runner with clear output
  - Proper test state cleanup
  - Improved error handling
  - Filtered bashunit warnings

## Installation 📦

### Fresh Install (Beta)
```bash
git clone https://github.com/mercateam/gitmerca.git
cd gitmerca
git checkout v2.0.0-beta.1
./install.sh
```

### Migrating from Previous Version
```bash
# 1. Clone the new version
git clone https://github.com/mercateam/gitmerca.git
cd gitmerca
git checkout v2.0.0-beta.1

# 2. Remove old installation
./legacy_uninstall.sh

# 3. Install new version
./install.sh
```

## Breaking Changes 🚨
If you're using the previous unversioned installation:
1. Installation directory changed from `~/my-git-custom-commands` to `~/gitmerca`
2. PATH entries in .zshrc have been updated
3. Utils are now properly separated from commands

## Features Overview 🛠️
- `git wrapup`: Automates PR workflow
  - Stashes changes
  - Rebases from develop
  - Runs pnpm changeset
  - Opens PR in browser

- `git reform`: Smart branch management
  - Safe rebasing from develop
  - Branch creation/switching
  - Change preservation

- `git cleanup`: Branch maintenance
  - Removes unused branches
  - Preserves develop branch
  - Safe state checking

## For mercateam Contributors 🏢
This beta release needs your testing and feedback:
- Try the migration process if you have the old version
- Test the new workflow in your daily tasks
- Report any issues or suggestions
- Help validate the breaking changes
- Suggest improvements to documentation

## Documentation 📚
- See [README.md](README.md) for full command documentation
- Each command supports `--help` for usage information
- Version information available via `--version` flag

## Path to Stable Release 🛣️
We plan to move to a stable v2.0.0 release after:
1. At least 2-3 team members have successfully migrated
2. No critical issues are found in daily usage
3. Installation/uninstallation process is verified
4. Edge cases are properly handled

## What's Next 🔭
After beta testing, we'll focus on:
- Addressing feedback from team testing
- Additional mercateam-specific workflows
- Enhanced PR templates
- Integration with other mercateam tools
- Workflow statistics and insights

## Credits 👏
Thanks to all mercateam members who tested and provided feedback on the previous unversioned implementation. Special thanks in advance to our beta testers!
