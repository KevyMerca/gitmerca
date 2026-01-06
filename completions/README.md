# Gitmerca Shell Completions

This directory contains shell completion scripts for gitmerca commands.

## Zsh

### Automatic Installation

Run the install script with completion support:

```bash
./install.sh
```

The installer will automatically set up completions if it detects Zsh.

### Manual Installation

1. **Option A: Add to fpath**

   Add this to your `~/.zshrc` before `compinit`:
   
   ```zsh
   fpath=(~/gitmerca/completions/zsh $fpath)
   autoload -Uz compinit && compinit
   ```

2. **Option B: Copy to system completion directory**

   ```bash
   # Find your zsh completions directory
   echo $fpath | tr ' ' '\n' | grep completion
   
   # Copy completions (example path, may vary)
   sudo cp completions/zsh/_git-* /usr/local/share/zsh/site-functions/
   ```

3. **Reload completions**
   
   ```bash
   # Remove cached completions and reload
   rm -f ~/.zcompdump && compinit
   ```

## What Gets Completed

After installation, you'll get tab completion for:

- `git reform <TAB>` - Shows branch names and options
- `git wrapup <TAB>` - Shows options like --branch, --no-changeset
- `git cleanup <TAB>` - Shows available options
- `git merca <TAB>` - Shows subcommands (update, doctor, list, config)

## Bash (Coming Soon)

Bash completions are planned for a future release.
