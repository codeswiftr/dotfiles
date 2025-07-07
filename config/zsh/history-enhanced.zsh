# ============================================================================
# Enhanced History and Autosuggestions Configuration
# Fish-like autosuggestions and intelligent history search
# ============================================================================

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Enhanced history options
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt SHARE_HISTORY            # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found
setopt HIST_IGNORE_SPACE        # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry
setopt HIST_VERIFY              # Don't execute immediately upon history expansion
setopt HIST_BEEP                # Beep when accessing nonexistent history

# ============================================================================
# ZSH Autosuggestions (Fish-like suggestions)
# ============================================================================

# Check if zsh-autosuggestions is available, if not suggest installation
if [[ ! -d "/opt/homebrew/share/zsh-autosuggestions" ]] && [[ ! -d "/usr/share/zsh-autosuggestions" ]] && [[ ! -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    # Auto-install zsh-autosuggestions if not present
    if command -v brew >/dev/null 2>&1 && [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔧 Installing zsh-autosuggestions for enhanced history completion..."
        brew install zsh-autosuggestions 2>/dev/null || {
            echo "⚠️  To enable fish-like autosuggestions, run: brew install zsh-autosuggestions"
        }
    elif [[ -f "/etc/debian_version" ]]; then
        echo "⚠️  To enable fish-like autosuggestions, run: sudo apt install zsh-autosuggestions"
    else
        echo "⚠️  To enable fish-like autosuggestions, install zsh-autosuggestions for your system"
    fi
fi

# Load zsh-autosuggestions from various possible locations
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Autosuggestions configuration
if command -v _zsh_autosuggest_start >/dev/null 2>&1; then
    # Suggestion strategy: prioritize history, then completion
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    
    # Suggestion highlighting
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"
    
    # Accept suggestion with right arrow or Ctrl+F
    bindkey '^F' autosuggest-accept
    bindkey '^[[C' autosuggest-accept  # Right arrow
    
    # Accept only one word of suggestion with Ctrl+Right
    bindkey '^[[1;5C' autosuggest-accept-word
    
    # Clear suggestion with Escape
    bindkey '^[' autosuggest-clear
    
    # Manual trigger (if needed)
    bindkey '^T' autosuggest-execute-suggestion
    
    # Performance optimization
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=true
    
    echo "✅ Fish-like autosuggestions enabled"
fi

# ============================================================================
# History Substring Search (Up/Down arrow based on typed text)
# ============================================================================

# Check if zsh-history-substring-search is available
if [[ ! -d "/opt/homebrew/share/zsh-history-substring-search" ]] && [[ ! -d "/usr/share/zsh-history-substring-search" ]] && [[ ! -f "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    # Auto-install if not present
    if command -v brew >/dev/null 2>&1 && [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔧 Installing zsh-history-substring-search for intelligent history navigation..."
        brew install zsh-history-substring-search 2>/dev/null || {
            echo "⚠️  To enable history substring search, run: brew install zsh-history-substring-search"
        }
    elif [[ -f "/etc/debian_version" ]]; then
        echo "⚠️  To enable history substring search, run: sudo apt install zsh-history-substring-search"
    fi
fi

# Load zsh-history-substring-search from various possible locations
if [[ -f "/opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "/opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
elif [[ -f "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
elif [[ -f "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

# History substring search configuration
if command -v history-substring-search-up >/dev/null 2>&1; then
    # Bind up and down arrows to substring search
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    
    # Also bind k and j in vicmd mode
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
    
    # Configuration options
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
    HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'  # Case insensitive
    
    echo "✅ History substring search enabled"
fi

# ============================================================================
# Additional History Features
# ============================================================================

# Better history navigation with Ctrl+R (integrates with fzf if available)
if command -v fzf >/dev/null 2>&1; then
    # fzf history search (Ctrl+R)
    bindkey '^R' fzf-history-widget
    
    # fzf file search (Ctrl+T)
    bindkey '^T' fzf-file-widget
    
    # fzf directory search (Alt+C)
    bindkey '\ec' fzf-cd-widget
else
    # Fallback to standard history search
    bindkey '^R' history-incremental-search-backward
fi

# Quick history functions
alias h='history'
alias hgrep='history | grep'
alias hclear='history -c && history -w'

# Show history statistics
hist-stats() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -20
}

# Search history by pattern
hist-search() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: hist-search <pattern>"
        return 1
    fi
    history | grep -i "$1"
}

# ============================================================================
# Performance Optimizations
# ============================================================================

# Optimize history loading
zshaddhistory() {
    # Skip certain commands from history
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    
    # Skip basic commands and cd commands
    [[ ${#line} -ge 5
        && ${cmd} != (ls|cd|pwd|exit|clear|history|h)
    ]]
}

# ============================================================================
# Integration with Existing Tools
# ============================================================================

# Ensure compatibility with atuin if installed
if command -v atuin >/dev/null 2>&1; then
    # atuin takes precedence for Ctrl+R if available
    eval "$(atuin init zsh)"
    echo "✅ Atuin history integration active"
fi

# Integration with zoxide for directory history
if command -v zoxide >/dev/null 2>&1; then
    # z command for directory jumping
    eval "$(zoxide init zsh)"
fi

echo "🚀 Enhanced history and autosuggestions configured!"
echo "💡 Usage:"
echo "   • Type any command - see suggestions appear automatically"
echo "   • Right arrow or Ctrl+F to accept full suggestion"
echo "   • Up/Down arrows to search history based on what you've typed"
echo "   • Ctrl+R for fuzzy history search"
echo "   • hist-stats to see your most used commands"