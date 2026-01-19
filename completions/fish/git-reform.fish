# Fish completion for git-reform
# Install: Copy to ~/.config/fish/completions/

complete -c git-reform -s h -l help -d "Show help message"
complete -c git-reform -s v -l version -d "Show version information"
complete -c git-reform -s f -l from -x -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "Base branch to rebase from"
complete -c git-reform -s d -l dry-run -d "Show what would be done without making changes"
complete -c git-reform -x -a "(git branch --format='%(refname:short)' 2>/dev/null)" -d "Target branch to create or switch to"
