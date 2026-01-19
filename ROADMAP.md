# Gitmerca Roadmap 🗺️

This document outlines the planned improvements and features for Gitmerca, organized by priority and complexity.

## Phase 0: Bug Fixes & Critical Issues 🐛 ✅

### Test Synchronization
- [x] Sync test output expectations with actual command messages
- [x] Add missing test cases for `--version` flag in all commands
- [x] Fix test infrastructure to use proper isolation (temp git repos)

### Code Fixes
- [x] Replace deprecated `git stash save` with `git stash push -m`
- [x] Add git repository validation at command start
- [x] Add `main` branch protection alongside `develop`
- [x] Fix bash 3.x compatibility (`readarray` → `while read`)

## Phase 1: Core Command Improvements 🛠️

### Command Features
- [x] Add `--version` flag support to all commands
- [ ] Implement `--dry-run` option for safe testing
- [x] Add detailed `--help` with examples for each command
- [x] Improve error messages with suggested fixes
- [x] Add `--no-changeset` / `-n` option for `git wrapup`
- [x] Add `--from` / `-f` option for `git reform` (custom base branch)
- [ ] Add `--include-current` option for `git cleanup`

### Safety Enhancements
- [x] Add checks for git repository before commands run
- [ ] Implement branch name validation
- [x] Add commit message validation (conventional commits)
- [x] Create backup mechanism for .zshrc changes

### Code Quality
- [ ] Add ShellCheck compliance for all scripts
- [ ] Consolidate command boilerplate into shared `init.sh`
- [ ] Support `NO_COLOR` environment variable standard
- [ ] Add better error context with help hints

## Phase 2: Developer Experience 👩‍💻

### Project Infrastructure
- [ ] Add GitHub Actions for CI/CD
- [ ] Set up automated release workflow
- [ ] Implement changelog automation with changesets
- [ ] Add test coverage reporting
- [ ] Add ShellCheck linting to CI pipeline

### Documentation
- [x] Update README with new command options
- [ ] Create CONTRIBUTING.md guidelines
- [ ] Add PR and issue templates
- [ ] Create command usage examples with screenshots
- [ ] Add troubleshooting guide
- [ ] Document architecture and design decisions

## Phase 3: Installation & Shell Support 🔧

### Shell Integration
- [x] Add Zsh completion for command arguments
- [x] Add Bash completion support
- [x] Add Fish shell completion support
- [x] Automatic completion installation with Oh My Zsh support
- [ ] Create configuration file for user/team defaults (`~/.gitmercaconfig`)

### Installation Experience
- [x] Add dependency checking (git, pnpm)
- [x] Improve error handling during installation
- [x] Add post-installation verification
- [x] Create upgrade command (`git merca update`)
- [ ] Add option to skip man page installation (avoid sudo)
- [ ] Support bash shell in addition to zsh

## Phase 4: Testing & Quality 🧪

### Test Infrastructure
- [x] Create isolated test repos for each test
- [x] Use bashunit's built-in assertions properly
- [ ] Add integration tests with real git repositories
- [ ] Create test fixtures for common scenarios
- [ ] Add performance benchmarks
- [ ] Implement end-to-end workflow tests

### Quality Assurance
- [ ] Add code quality checks (ShellCheck)
- [ ] Implement style guide enforcement
- [ ] Add security scanning
- [ ] Create release checklist

## Phase 5: Advanced Features 🚀

### GitHub Integration
- [ ] Add GitHub API integration for PR descriptions
- [ ] Support custom PR templates
- [ ] Add PR status checking
- [ ] Implement PR review automation

### Workflow Optimization
- [ ] Add workflow statistics tracking
- [ ] Create performance monitoring
- [ ] Implement command suggestions
- [ ] Add workflow analytics dashboard
- [ ] Interactive branch selection with `fzf` for `git cleanup`

## Phase 6: Team Features 👥

### Collaboration
- [ ] Add team configuration sharing
- [ ] Create workflow templates
- [ ] Add team statistics
- [ ] Implement best practice enforcement

### Monitoring & Feedback
- [ ] Add opt-in telemetry
- [ ] Create error reporting system
- [ ] Add update notifications
- [ ] Implement user feedback collection

## Future Considerations 🔮

### Potential Features
- Integration with other mercateam tools
- Custom workflow creation UI
- Branch strategy automation
- Workflow compliance checking

### Long-term Goals
- Support for multiple Git hosting platforms
- Plugin system for custom commands
- Team workflow analytics
- AI-powered suggestions

## Contributing 🤝

Want to help implement these features? See our [CONTRIBUTING.md](CONTRIBUTING.md) guide.

Each feature will be tracked as a GitHub issue with detailed requirements and acceptance criteria. We welcome contributions from team members and encourage discussion on implementation approaches.

## Priority Guidelines 📋

When implementing features:
1. **Phase 0 first** - Fix bugs and critical issues before adding new features ✅
2. Focus on stability and safety
3. Prioritize features that benefit the whole team
4. Consider backward compatibility
5. Maintain simple, intuitive interfaces
6. Add comprehensive tests and documentation

## Quick Wins 🎯

Remaining quick wins:

| Item | Effort | Phase |
|------|--------|-------|
| Consolidate command boilerplate | 30 min | 1 |
| Add ShellCheck to CI | 30 min | 2 |
| Add `--dry-run` option | 1 hr | 1 |
| Skip sudo for man pages (optional) | 20 min | 3 |

## Timeline 📅

This roadmap is flexible and will evolve based on:
- Team feedback from v2.2.1
- Usage patterns and pain points
- Available resources and priorities
- New requirements from mercateam

Features may be implemented out of order based on team needs and contributor interest.

## Changelog

- **2025-01**: Phase 3 Shell Integration complete! Added Zsh, Bash, and Fish completion support with automatic installation and Oh My Zsh compatibility
- **2025-01**: Phase 0 complete! Added `-f/--from` to reform, `-n/--no-changeset` to wrapup, overhauled test infrastructure
- **2024-01**: Added Phase 0 for bug fixes, quick wins table, and reorganized priorities
