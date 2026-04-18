# =============================================================================
# ZSH Completions Configuration
# Enhanced tab completion for modern development tools
# =============================================================================

# Add custom completions directory to fpath
if [[ -d "$DOTFILES_DIR/completions" ]]; then
    fpath=("$DOTFILES_DIR/completions" $fpath)
fi

# Initialize completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Enhanced completion options
setopt AUTO_MENU           # Show completion menu on successive tab press
setopt COMPLETE_IN_WORD    # Allow completion in middle of word
setopt ALWAYS_TO_END       # Move cursor to end after completion
setopt HASH_LIST_ALL       # Hash entire command path first
setopt COMPLETEALIASES     # Complete aliases
setopt COMPLETE_ALIASES    # Complete command aliases
setopt LIST_AMBIGUOUS      # Show ambiguous completions immediately
setopt MENU_COMPLETE       # Insert first match immediately

# Disable some options
unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor

# Completion styling
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache

# Group completions by category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%F{blue}--- %d ---%f%b'
zstyle ':completion:*:messages' format '%F{purple}--- %d ---%f'
zstyle ':completion:*:warnings' format '%F{red}--- No matches found ---%f'

# Enhanced file completion
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Process completion
zstyle ':completion:*:processes' command 'ps -u $USERNAME -o pid,user,comm -w -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

# Directory completion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*' special-dirs true

# SSH/SCP completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr

# Git completion enhancements
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-branch:*' sort false

# Docker completion
if command -v docker >/dev/null 2>&1; then
    zstyle ':completion:*:docker:*' option-stacking yes
    zstyle ':completion:*:docker-*:*' option-stacking yes
fi

# Modern CLI tools completions
# Load completions for modern tools if available

# uv (Python package manager)
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh 2>/dev/null || true)"
fi

# bun (JavaScript runtime)
if command -v bun >/dev/null 2>&1; then
    eval "$(bun completions 2>/dev/null || true)"
fi

# mise (version manager)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh 2>/dev/null || true)"
fi

# GitHub CLI
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s zsh 2>/dev/null || true)"
fi

# kubectl (if available)
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh 2>/dev/null || true)
fi

# Docker compose
if command -v docker-compose >/dev/null 2>&1; then
    eval "$(docker-compose completion zsh 2>/dev/null || true)"
fi

# Terraform (if available)
if command -v terraform >/dev/null 2>&1; then
    # Zsh uses compdef; 'complete' is bash-only
    compdef _gnu_generic terraform
fi

# AWS CLI (if available)
if command -v aws >/dev/null 2>&1; then
    # Prefer aws zsh completion if available
    if type _aws >/dev/null 2>&1; then
        compdef _aws aws
    elif command -v aws_completer >/dev/null 2>&1; then
        compdef '_arguments "*: :($(aws_completer 2>/dev/null))"' aws
    fi
fi

# Custom completions for dotfiles commands
# These are loaded from the completions directory

# Reload completions function
reload-completions() {
    local compfiles=(${ZDOTDIR:-$HOME}/.zcompdump*)
    if [[ $#compfiles -gt 0 ]]; then
        rm -f $compfiles
    fi
    compinit -U
    echo "Completions reloaded!"
}

# DOT CLI specific completion helpers
_dot_completion_helper() {
    # Helper function for dynamic DOT completions
    case $words[2] in
        project)
            case $words[3] in
                init)
                    # Dynamic project template completion
                    if [[ -d "$DOTFILES_DIR/templates" ]]; then
                        local templates=($(ls "$DOTFILES_DIR/templates" 2>/dev/null))
                        compadd -a templates
                    fi
                    ;;
            esac
            ;;
    esac
}

# Enhanced file and directory completion
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' expand prefix suffix

# Fuzzy matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Menu selection with vim-like navigation
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Accept completion with enter
bindkey -M menuselect '^M' .accept-line

# Modern completion plugins integration
# Load additional completion sources if available

# Load completion for custom scripts
if [[ -d "$DOTFILES_DIR/bin" ]]; then
    for script in "$DOTFILES_DIR/bin"/*; do
        if [[ -x "$script" && -f "$script" ]]; then
            local script_name=$(basename "$script")
            # Check if completion exists
            if [[ -f "$DOTFILES_DIR/completions/_$script_name" ]]; then
                autoload -Uz "_$script_name"
            fi
        fi
    done
fi

# Completion debugging (uncomment for troubleshooting)
# zstyle ':completion:*' verbose yes
# zstyle ':completion:*:descriptions' format '%B%d%b'
# zstyle ':completion:*:messages' format '%d'
# zstyle ':completion:*:warnings' format 'No matches for: %d'
# zstyle ':completion:*' group-name ''

# Performance optimization
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Load any additional completions from the completions directory
if [[ -d "$DOTFILES_DIR/completions" ]]; then
    for completion in "$DOTFILES_DIR/completions"/_*; do
        if [[ -f "$completion" ]]; then
            autoload -Uz "$(basename "$completion")"
        fi
    done
fi

# -----------------------------------------------------------------------------
# tmux session completion for `ta` (attach)
# Restores fzf-friendly completion: `ta <TAB>` lists sessions
# -----------------------------------------------------------------------------
_ta() {
    local -a sessions
    sessions=(${(f)"$(tmux list-sessions -F '#S' 2>/dev/null)"})
    if (( ${#sessions[@]} )); then
        compadd -a sessions
    fi
}
compdef _ta ta