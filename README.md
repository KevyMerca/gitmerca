# Git Custom Commands 🛠️

Enhance your Git workflow with these carefully crafted custom commands! This toolkit provides a set of commands to automate common Git operations and make your development process smoother.

## 🚀 Quick Start

Run the installation script to get started:

```sh
./install.sh
```

### What the installer does:

1. 📁 Creates a `my-git-custom-commands` directory in your home folder
2. 📋 Copies the custom Git commands to this directory
3. 🔄 Adds the directory to your `PATH` in `.zshrc`
4. ✨ Reloads your shell environment

## 🎯 Available Commands

| Command       | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `git wrapup`  | Automates your PR workflow: stashes changes, rebases from `develop`, runs `pnpm changeset`, commits with your message, pushes changes, and opens a PR in your browser. |
| `git reform`  | Streamlines branch management: stashes changes, rebases from `develop`, optionally checks out or creates a target branch, and restores your changes. |
| `git cleanup` | Keeps your local branches tidy by removing all local branches except `develop`. |

## 🏗️ Project Structure

```
├── src/
│   ├── commands/        # Git command implementations
│   │   ├── git-cleanup
│   │   ├── git-reform
│   │   └── git-wrapup
│   └── utils/           # Shared utility functions
│       └── git-utils    # Common Git operations
├── tests/              # Test files
├── lib/                # External dependencies
└── install.sh         # Installation script
```

## 🧪 Running Tests

We use the `bashunit` testing framework to ensure reliability. Tests are located in the `tests` directory.

Run all tests with:

```sh
./lib/bashunit ./tests
```

## 💡 Tips

- The commands are designed to work with a `develop` branch as the main integration branch
- `git wrapup` automatically opens a PR in your default browser after pushing
- All commands include safety checks to prevent unintended operations

## 🤝 Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or new features!

## 📝 License

This project is open source and available under the MIT License.