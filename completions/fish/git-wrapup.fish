# Fish completion for git-wrapup
# Install: Copy to ~/.config/fish/completions/

complete -c git-wrapup -s h -l help -d "Show help message"
complete -c git-wrapup -s v -l version -d "Show version information"
complete -c git-wrapup -s b -l branch -x -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "Create or switch to branch"
complete -c git-wrapup -s f -l from -x -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "Base branch for pull request"
complete -c git-wrapup -s n -l no-changeset -d "Skip running pnpm changeset"
complete -c git-wrapup -s fnb -x -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "Shorthand for -f <current-branch> -n -b"
complete -c git-wrapup -s d -l dry-run -d "Show what would be done without making changes"
