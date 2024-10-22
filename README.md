# Git Custom Commands

This repository provides custom Git commands to enhance your workflow. The installation script (`install.sh`) sets up the environment by performing the following steps:

1. **Directory Setup**: Creates a directory named `my-git-custom-commands` in your home directory to store the custom Git command scripts.
2. **File Copying**: Copies the custom Git command scripts (contained in the `commands` folder) to the newly created directory.
3. **PATH Configuration**: Adds the directory to your `PATH` in your `.zshrc` file if it is not already included, ensuring that the custom commands can be executed from anywhere in the terminal.
4. **Environment Reload**: Sources the `.zshrc` file to apply the changes immediately.

After running the installation script, you will be able to use the custom Git commands to streamline your Git operations.

## Available Commands

| Command       | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| `git wrapup`  | Stashes changes, rebases from `develop`, runs `pnpm changeset`, commits, and pushes changes. |
| `git reform`  | Stashes changes, rebases from `develop`, optionally checks out or creates a target branch, and pops the stash. |

Each command is designed to automate and streamline common Git workflows, reducing the need for manual intervention and minimizing the risk of errors.