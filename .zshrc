# =============================================================================
# High-Performance ZSH Configuration - 2025 Optimized Edition
# Revolutionary shell startup optimization with intelligent loading
# =============================================================================

# ============================================================================ 
# Performance Initialization - Load First for Timing
# ============================================================================ 
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZSH_CONFIG_DIR="$DOTFILES_DIR/config/zsh"

# Enable performance timing in development mode
DOTFILES_PERF_TIMING=${DOTFILES_PERF_TIMING:-false}

# Ultra-fast timing function (loaded first)
perf_time() {
    if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
        printf "⏱️  %s: %.6f\n" "$1" "$EPOCHREALTIME" >&2
    fi
}

perf_time "ZSH configuration start"

# ============================================================================ 
# Performance System - Core Performance Engine
# ============================================================================ 
perf_time "Loading performance system"

# Load performance optimization system
[[ -f "$ZSH_CONFIG_DIR/performance.zsh" ]] && source "$ZSH_CONFIG_DIR/performance.zsh"

# Load advanced performance library
[[ -f "$DOTFILES_DIR/lib/performance-advanced.sh" ]] && source "$DOTFILES_DIR/lib/performance-advanced.sh"

perf_time "Performance system loaded"

# ============================================================================ 
# Core Configuration - Essential Settings
# ============================================================================ 
perf_time "Loading core configuration"

# Core shell settings
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"

# Environment and PATH setup
[[ -f "$ZSH_CONFIG_DIR/environment.zsh" ]] && source "$ZSH_CONFIG_DIR/environment.zsh"
[[ -f "$ZSH_CONFIG_DIR/paths.zsh" ]] && source "$ZSH_CONFIG_DIR/paths.zsh"

perf_time "Core configuration loaded"

# ============================================================================ 
# Tool Initialization - Optimized Loading Strategy
# ============================================================================ 
perf_time "Starting tool initialization"

# Choose tool loading strategy based on performance mode
if [[ -f "$ZSH_CONFIG_DIR/tools-optimized.zsh" ]] && [[ "$DOTFILES_PERFORMANCE_MODE" != "legacy" ]]; then
    # Use optimized tool loading (recommended)
    source "$ZSH_CONFIG_DIR/tools-optimized.zsh"
else
    # Fallback to standard tool loading
    [[ -f "$ZSH_CONFIG_DIR/tools.zsh" ]] && source "$ZSH_CONFIG_DIR/tools.zsh"
fi

perf_time "Tool initialization complete"

# ============================================================================ 
# Function Libraries - Modular Loading
# ============================================================================ 
perf_time "Loading function libraries"

# Core functions
[[ -f "$ZSH_CONFIG_DIR/functions.zsh" ]] && source "$ZSH_CONFIG_DIR/functions.zsh"

# Aliases (fast loading)
[[ -f "$ZSH_CONFIG_DIR/aliases.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases.zsh"

# Development optimizations
[[ -f "$ZSH_CONFIG_DIR/optimization.zsh" ]] && source "$ZSH_CONFIG_DIR/optimization.zsh"

perf_time "Function libraries loaded"

# ============================================================================ 
# Conditional Feature Loading - Performance-Aware
# ============================================================================ 
perf_time "Loading conditional features"

# AI integration (load based on performance mode)
if [[ "$DOTFILES_PERFORMANCE_MODE" != "fast" ]] && [[ -z "$DOTFILES_FAST_MODE" ]]; then
    if [[ -f "$ZSH_CONFIG_DIR/ai.zsh" ]] || [[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]]; then
        # Load AI features asynchronously for better performance
        {
            [[ -f "$ZSH_CONFIG_DIR/ai-enhanced.zsh" ]] && source "$ZSH_CONFIG_DIR/ai-enhanced.zsh"
            [[ -f "$ZSH_CONFIG_DIR/ai.zsh" ]] && source "$ZSH_CONFIG_DIR/ai.zsh"
        } &
    fi
fi

# Testing frameworks (load on demand)
if [[ "$DOTFILES_PERFORMANCE_MODE" == "full" ]] && [[ -z "$DOTFILES_FAST_MODE" ]]; then
    [[ -f "$ZSH_CONFIG_DIR/testing.zsh" ]] && source "$ZSH_CONFIG_DIR/testing.zsh"
fi

perf_time "Conditional features loaded"

# ============================================================================ 
# User Customization - Load Last
# ============================================================================ 
perf_time "Loading user customizations"

# Legacy configuration (if migrating)
if [[ -f "$DOTFILES_DIR/.zshrc.legacy" ]]; then
    source "$DOTFILES_DIR/.zshrc.legacy"
fi

# User-specific customizations (highest priority)
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

perf_time "User customizations loaded"

# ============================================================================ 
# Startup Completion and Status
# ============================================================================ 
perf_time "Configuration finalization"

# Auto-update check (async, non-blocking)
if [[ "$DOTFILES_PERFORMANCE_MODE" != "fast" ]] && [[ $- == *i* ]] && [[ -z "$DOTFILES_FAST_MODE" ]]; then
    { 
        if [[ -f "$DOTFILES_DIR/lib/version.sh" ]]; then
            source "$DOTFILES_DIR/lib/version.sh"
            auto_update_check
        fi
    } &
fi

perf_time "ZSH configuration complete"

# ============================================================================ 
# Welcome Message - Performance-Aware Display
# ============================================================================ 

# Display loading status (interactive shells only)
if [[ $- == *i* ]] && [[ -z "$DOTFILES_QUIET" ]]; then
    # Performance mode indicator
    local perf_indicator=""
    case "$DOTFILES_PERFORMANCE_MODE" in
        "fast") perf_indicator=" ⚡ Fast Mode" ;; 
        "balanced") perf_indicator=" ⚖️  Balanced Mode" ;; 
        "full") perf_indicator=" 🚀 Full Mode" ;; 
    esac
    
    # Show startup time if timing is enabled
    local startup_time=""
    if [[ "$DOTFILES_PERF_TIMING" == "true" ]]; then
        startup_time=" ($(printf "%.3f" "$EPOCHREALTIME")s)"
    fi
    
    # Compact status display
    echo "🚀 ZSH Ready${perf_indicator}${startup_time} - $(date +%H:%M)"
    
    # Tool availability (compact format)
    local available_tools=()
    local tools=("starship" "zoxide" "eza" "bat" "rg" "fd" "fzf" "mise" "atuin")
    for tool in "${tools[@]}"; do
        command -v "$tool" >/dev/null && available_tools+=("$tool")
    done
    
    if [[ ${#available_tools[@]} -gt 0 ]]; then
        echo "🔧 Tools: ${available_tools[*]}"
    fi
    
    # AI tools (if available and not in fast mode)
    if [[ "$DOTFILES_PERFORMANCE_MODE" != "fast" ]]; then
        local ai_tools=()
        command -v claude >/dev/null && ai_tools+=("claude")
        command -v aider >/dev/null && ai_tools+=("aider")
        command -v copilot >/dev/null && ai_tools+=("copilot")
        
        if [[ ${#ai_tools[@]} -gt 0 ]]; then
            echo "🤖 AI: ${ai_tools[*]}"
        fi
    fi
    
    # Quick tips (minimal)
    echo "💡 'perf-status' for performance info | 'perf-bench' for benchmark"
    
    # Version info (compact)
    local version=$(cat "$DOTFILES_DIR/VERSION" 2>/dev/null || echo "dev")
    echo "📦 Dotfiles v$version | Use 'dot update' to check for updates"
fi

# ============================================================================ 
# Performance Analytics (Optional)
# ============================================================================ 

# Collect startup performance data (if enabled)
if [[ "$DOTFILES_COLLECT_PERF_DATA" == "true" ]] && [[ $- == *i* ]]; then
    { 
        local perf_log="$HOME/.cache/dotfiles/startup_times.log"
        mkdir -p "$(dirname "$perf_log")"
        echo "$(date +%s),$(printf "%.6f" "$EPOCHREALTIME"),$DOTFILES_PERFORMANCE_MODE" >> "$perf_log"
        
        # Keep only last 100 entries
        tail -100 "$perf_log" > "$perf_log.tmp" && mv "$perf_log.tmp" "$perf_log"
    } &
fi

# ============================================================================ 
# Final Performance Check
# ============================================================================ 

# If startup is too slow, suggest optimizations
if [[ "$DOTFILES_PERF_TIMING" == "true" ]] && [[ $- == *i* ]]; then
    local total_time=$(printf "%.3f" "$EPOCHREALTIME")
    if (( $(echo "$total_time > 1.0" | bc -l 2>/dev/null || echo 0) )); then
        echo "⚠️  Slow startup (${total_time}s). Try: export DOTFILES_FAST_MODE=1"
    fi
fi