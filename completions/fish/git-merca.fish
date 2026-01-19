# Fish completion for git-merca
# Install: Copy to ~/.config/fish/completions/

complete -c git-merca -s h -l help -d "Show help message"
complete -c git-merca -s v -l version -d "Show version information"
complete -c git-merca -f -a "update" -d "Update gitmerca to the latest version"
complete -c git-merca -f -a "uninstall" -d "Remove gitmerca from your system"
complete -c git-merca -f -a "doctor" -d "Run health checks on the installation"
complete -c git-merca -f -a "list" -d "Show all available commands"
complete -c git-merca -f -a "config" -d "View or edit configuration"
complete -c git-merca -f -a "help" -d "Show help message"

# Config subcommand completions
complete -c git-merca -n '__fish_seen_subcommand_from config' -f -a "show" -d "Show current configuration"
complete -c git-merca -n '__fish_seen_subcommand_from config' -f -a "edit" -d "Edit configuration file"
complete -c git-merca -n '__fish_seen_subcommand_from config' -f -a "path" -d "Show configuration file path"
