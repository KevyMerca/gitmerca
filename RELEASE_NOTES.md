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
