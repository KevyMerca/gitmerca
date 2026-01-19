# Gitmerca Shell Completions

This directory contains shell completion scripts for gitmerca commands.

## Automatic Installation

Run the install script to automatically install completions for your shell:

```bash
./install.sh
```

The installer will detect your shell (Zsh, Bash, or Fish) and install the appropriate completions automatically.

## Zsh

### Automatic Installation

The installer automatically detects your Zsh setup and installs completions appropriately:

- **Oh My Zsh users**: Completions are copied to `~/.oh-my-zsh/completions/` (automatically in fpath)
- **Standard Zsh**: Completions are copied to system directory or added to `fpath` in `~/.zshrc`

**Important for Oh My Zsh users**: After installation, you may need to clear the completion cache:
```bash
rm ~/.zcompdump* && exec zsh
```

### Manual Installation

1. **Option A: For Oh My Zsh users**

   Copy completions to Oh My Zsh's completion directory:
   
   ```bash
   mkdir -p ~/.oh-my-zsh/completions
   cp ~/gitmerca/completions/zsh/_git-* ~/.oh-my-zsh/completions/
   rm ~/.zcompdump* && exec zsh
   ```

2. **Option B: Add to fpath (standard Zsh)**

   Add this to your `~/.zshrc` **before** `source $ZSH/oh-my-zsh.sh` (if using Oh My Zsh) or before `compinit`:
   
   ```zsh
   fpath=(~/gitmerca/completions/zsh $fpath)
   autoload -Uz compinit && compinit
   ```

3. **Option C: Copy to system completion directory**

   ```bash
   # Find your zsh completions directory
   echo $fpath | tr ' ' '\n' | grep completion
   
   # Copy completions (example path, may vary)
   sudo cp completions/zsh/_git-* /usr/local/share/zsh/site-functions/
   ```

4. **Reload completions**
   
   ```bash
   # Remove cached completions and reload
   rm -f ~/.zcompdump* && exec zsh
   # or
   rm -f ~/.zcompdump* && compinit
   ```

## Bash

### Automatic Installation

The installer automatically sets up Bash completions by:
- Copying completion files to `~/.bash_completion.d/`
- Adding source commands to your `~/.bashrc` or `~/.bash_profile`

### Manual Installation

1. **Copy completion files**

   ```bash
   mkdir -p ~/.bash_completion.d
   cp completions/bash/git-* ~/.bash_completion.d/
   ```

2. **Source in your bash config**

   Add this to your `~/.bashrc` or `~/.bash_profile`:
   
   ```bash
   if [ -d ~/.bash_completion.d ]; then
       for file in ~/.bash_completion.d/git-*; do
           [ -f "$file" ] && source "$file"
       done
   fi
   ```

3. **Reload shell**

   ```bash
   source ~/.bashrc
   # or
   source ~/.bash_profile
   ```

## Fish

### Automatic Installation

The installer automatically sets up Fish completions by copying `.fish` files to `~/.config/fish/completions/`

### Manual Installation

1. **Copy completion files**

   ```bash
   mkdir -p ~/.config/fish/completions
   cp completions/fish/*.fish ~/.config/fish/completions/
   ```

2. **Reload shell**

   ```fish
   # Fish automatically loads completions, just restart your shell
   # or run:
   exec fish
   ```

## What Gets Completed

After installation, you'll get tab completion for:

- `git reform <TAB>` - Shows branch names and options (`-f`, `--from`, `-d`, `--dry-run`)
- `git wrapup <TAB>` - Shows options like `--branch`, `--from`, `--no-changeset`, `-fnb`
- `git cleanup <TAB>` - Shows available options (`-y`, `--yes`, `-h`, `--help`)
- `git merca <TAB>` - Shows subcommands (update, doctor, list, config, help)

### Branch Name Completion

All commands that accept branch names will automatically complete with your local git branches when you press `<TAB>`.
