#!/usr/bin/env bash
# ============================================================================
# Advanced Performance Optimizations
# Lazy loading and completion caching for shell startup
# ============================================================================

# Enhanced lazy loading with intelligent wrapper
smart_lazy_load() {
    local cmd="$1"
    local load_func="$2"

    eval "$cmd() {
        unfunction $cmd 2>/dev/null
        $load_func
        $cmd \"\$@\"
    }"
}

# Compile all completion files for maximum speed
compile_all_completions() {
    local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -f "$zcompdump" && (! -f "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
        zcompile "$zcompdump"
    fi

    for comp_file in "${ZDOTDIR:-$HOME}"/.zsh_cache/*(.N); do
        if [[ -f "$comp_file" && (! -f "${comp_file}.zwc" || "$comp_file" -nt "${comp_file}.zwc") ]]; then
            zcompile "$comp_file"
        fi
    done
}
