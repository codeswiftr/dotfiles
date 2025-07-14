# ============================================================================
# Dynamic Terminal Title Integration with Tmux
# Automatically sets terminal window/tab title to show tmux session and window
# ============================================================================

# Direct function to set macOS Terminal.app window title
set_terminal_title() {
    local title="$1"
    
    # Validate input
    if [[ -z "$title" ]]; then
        echo "❌ Error: Title cannot be empty"
        echo "Usage: set_terminal_title <title>"
        return 1
    fi
    
    # Sanitize title (remove control characters and limit length)
    title=$(echo "$title" | tr -d '\000-\037\177' | head -c 100)
    
    if [[ -n "$title" ]]; then
        # Use BEL terminator (\007) for better macOS Terminal.app compatibility
        printf '\033]2;%s\007' "$title"
        # Also set tab title for iTerm2
        printf '\033]1;%s\007' "$title"
    else
        echo "⚠️  Warning: Title was empty after sanitization"
        return 1
    fi
}

# Function to update terminal title based on tmux state
update_terminal_title() {
    # Check if we're inside tmux
    if [[ -n "$TMUX" ]]; then
        # Get tmux session name and window info
        local session_name=$(tmux display-message -p '#S' 2>/dev/null)
        local window_index=$(tmux display-message -p '#I' 2>/dev/null)
        local window_name=$(tmux display-message -p '#W' 2>/dev/null)
        local pane_title=$(tmux display-message -p '#T' 2>/dev/null)
        
        # Construct title based on available information
        if [[ -n "$session_name" && -n "$window_name" ]]; then
            # Format: "session:window" or "session:index-name" for clarity
            if [[ "$window_name" != "zsh" && "$window_name" != "bash" ]]; then
                # Use descriptive window name, but clean it up
                local clean_window_name=$(echo "$window_name" | sed 's/\[.*\]//g' | xargs)
                local title="$session_name:$clean_window_name"
            else
                # Use index when window name is generic
                local title="$session_name:$window_index"
            fi
            
            # Don't add pane title for now to keep it clean
            # if [[ -n "$pane_title" && "$pane_title" != "$(hostname)" && "$pane_title" != "zsh" && "$pane_title" != "bash" ]]; then
            #     title="$title [$pane_title]"
            # fi
        else
            # Fallback to session name only
            local title="${session_name:-tmux}"
        fi
    else
        # Not in tmux, use current directory or hostname
        local title="$(basename "$PWD")"
        
        # If in home directory, show hostname instead
        if [[ "$PWD" == "$HOME" ]]; then
            title="$(hostname -s)"
        fi
    fi
    
    # Set the macOS Terminal.app window title using our direct function
    set_terminal_title "$title"
}

# Function to set up automatic title updates
setup_tmux_title_integration() {
    # Update title when changing directories
    chpwd_functions+=(update_terminal_title)
    
    # Update title before each prompt (catches tmux session/window changes)
    precmd_functions+=(update_terminal_title)
    
    # Update title when entering/exiting tmux
    if [[ -n "$TMUX" ]]; then
        # Set up tmux hooks for real-time updates
        tmux set-hook -g after-new-window 'run-shell "echo \\"#{session_name}:#{window_name}\\" > /tmp/tmux-title-$$"' 2>/dev/null || true
        tmux set-hook -g after-select-window 'run-shell "echo \\"#{session_name}:#{window_name}\\" > /tmp/tmux-title-$$"' 2>/dev/null || true
        tmux set-hook -g after-rename-window 'run-shell "echo \\"#{session_name}:#{window_name}\\" > /tmp/tmux-title-$$"' 2>/dev/null || true
    fi
    
    # Initial title update
    update_terminal_title
}

# Enhanced tmux session management with title updates
tmux_session_with_title() {
    local session_name="$1"
    
    if [[ -z "$session_name" ]]; then
        echo "Usage: tmux_session_with_title <session_name>"
        return 1
    fi
    
    # Create or attach to session
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "📱 Attaching to existing session: $session_name"
        tmux attach-session -t "$session_name"
    else
        echo "🚀 Creating new session: $session_name"
        tmux new-session -s "$session_name"
    fi
    
    # Update title after tmux session change
    update_terminal_title
}

# Smart tmux session picker with title updates
tmux_session_picker() {
    # List all sessions
    local sessions=($(tmux list-sessions -F "#{session_name}" 2>/dev/null))
    
    if [[ ${#sessions[@]} -eq 0 ]]; then
        echo "No tmux sessions found. Creating new session..."
        read "session_name?Enter session name: "
        tmux_session_with_title "$session_name"
        return
    fi
    
    echo "📋 Available tmux sessions:"
    for i in {1..${#sessions[@]}}; do
        echo "  $i) ${sessions[$i]}"
    done
    echo "  n) Create new session"
    echo "  q) Quit"
    
    read "choice?Select session (1-${#sessions[@]}, n, q): "
    
    case "$choice" in
        [1-9]*)
            if [[ $choice -le ${#sessions[@]} ]]; then
                tmux_session_with_title "${sessions[$choice]}"
            else
                echo "Invalid selection"
            fi
            ;;
        n|N)
            read "session_name?Enter new session name: "
            tmux_session_with_title "$session_name"
            ;;
        q|Q)
            echo "Cancelled"
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
}

# Advanced tmux window title management
tmux_window_title() {
    local title="$1"
    
    if [[ -z "$TMUX" ]]; then
        echo "Not in a tmux session"
        return 1
    fi
    
    if [[ -z "$title" ]]; then
        # Show current window info
        local session=$(tmux display-message -p '#S')
        local window=$(tmux display-message -p '#W')
        local index=$(tmux display-message -p '#I')
        echo "Current: $session:$index ($window)"
        
        read "new_title?Enter new window title (current: $window): "
        title="$new_title"
    fi
    
    if [[ -n "$title" ]]; then
        tmux rename-window "$title"
        update_terminal_title
        echo "✅ Window renamed to: $title"
    fi
}

# Project-based session management with automatic titles
tmux_project_session() {
    local project_dir="$1"
    
    # If no directory specified, use current directory
    if [[ -z "$project_dir" ]]; then
        project_dir="$PWD"
    fi
    
    # Validate directory exists and is accessible
    if [[ ! -d "$project_dir" ]]; then
        echo "❌ Error: Directory '$project_dir' does not exist"
        return 1
    fi
    
    if [[ ! -r "$project_dir" ]]; then
        echo "❌ Error: Directory '$project_dir' is not readable"
        return 1
    fi
    
    # Convert to absolute path with error handling
    if ! project_dir="$(cd "$project_dir" && pwd 2>/dev/null)"; then
        echo "❌ Error: Cannot access directory '$project_dir'"
        return 1
    fi
    
    local project_name="$(basename "$project_dir")"
    
    # Validate project name for tmux compatibility
    if [[ "$project_name" =~ [[:space:]:] ]]; then
        echo "⚠️  Warning: Project name contains spaces or colons, sanitizing..."
        project_name=$(echo "$project_name" | sed 's/[[:space:]:_]/-/g')
        echo "Using session name: $project_name"
    fi
    
    # Check if session already exists
    if tmux has-session -t "$project_name" 2>/dev/null; then
        echo "📱 Attaching to project session: $project_name"
        tmux attach-session -t "$project_name"
    else
        echo "🚀 Creating project session: $project_name"
        if ! tmux new-session -s "$project_name" -c "$project_dir"; then
            echo "❌ Error: Failed to create tmux session"
            return 1
        fi
    fi
    
    update_terminal_title
}

# Aliases for convenient session management
alias tm='tmux_session_picker'
alias tms='tmux_session_with_title'
alias tmw='tmux_window_title'
alias tmp='tmux_project_session'

# Direct terminal title control
alias title='set_terminal_title'

# Quick session shortcuts
alias tmain='tmux_session_with_title main'
alias tdev='tmux_session_with_title dev'
alias twork='tmux_session_with_title work'
alias ttest='tmux_session_with_title test'

# Window management shortcuts
alias twin='tmux new-window'
alias twls='tmux list-windows'
alias twrn='tmux_window_title'

# Enhanced session info
tmux_session_info() {
    if [[ -n "$TMUX" ]]; then
        echo "📱 Tmux Session Info:"
        echo "   Session: $(tmux display-message -p '#S')"
        echo "   Window:  $(tmux display-message -p '#I: #W')"
        echo "   Pane:    $(tmux display-message -p '#P')"
        echo "   Title:   $(tmux display-message -p '#T')"
        echo ""
        echo "🪟 All Windows:"
        tmux list-windows -F "   #{window_index}: #{window_name} #{?window_active,(active),}"
    else
        echo "Not in a tmux session"
    fi
}

alias tinfo='tmux_session_info'

# Integration with terminal title for non-tmux environments
update_simple_title() {
    if [[ -z "$TMUX" ]]; then
        local title="$(basename "$PWD")"
        if [[ "$PWD" == "$HOME" ]]; then
            title="$(hostname -s)"
        fi
        printf '\033]2;%s\033\\' "$title"
    fi
}

# Setup title integration
if [[ -z "$TMUX_TITLE_SETUP_DONE" ]]; then
    setup_tmux_title_integration
    export TMUX_TITLE_SETUP_DONE=1
    
    # Also update title for non-tmux directory changes
    if [[ -z "$TMUX" ]]; then
        chpwd_functions+=(update_simple_title)
        precmd_functions+=(update_simple_title)
    fi
fi

# Special handling for tmux attach/detach
tmux_attach_hook() {
    if [[ -n "$1" ]]; then
        tmux_session_with_title "$1"
    else
        tmux_session_picker
    fi
}

# Override default tmux attach behavior
alias ta='tmux_attach_hook'

echo "🪟 Dynamic terminal titles configured!"
echo "💡 Commands:"
echo "   tm          # Session picker"
echo "   tms <name>  # Create/attach to named session"
echo "   tmw [title] # Set window title"
echo "   tmp [dir]   # Project-based session"
echo "   tinfo       # Show session info"