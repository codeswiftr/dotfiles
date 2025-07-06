# =============================================================================
# macOS-specific ZSH Configuration
# Platform-specific settings and optimizations for macOS
# =============================================================================

# macOS-specific environment variables
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_BUNDLE_FILE="$DOTFILES_DIR/config/platform/Brewfile"

# Homebrew path setup based on architecture
if [[ "$PLATFORM_ARCH" == "arm64" ]]; then
    # Apple Silicon (M1/M2/M3)
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export MANPATH="/opt/homebrew/share/man:${MANPATH:-}"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
else
    # Intel Macs
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="/usr/local/Cellar"
    export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# macOS-specific aliases
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewinfo='brew list --versions && brew doctor'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias documents='cd ~/Documents'

# Quick access to system preferences
alias sysprefs='open -b com.apple.systempreferences'
alias activity='open -a "Activity Monitor"'
alias console='open -a "Console"'

# Screenshot utilities
alias screenshot='screencapture -c'
alias screenshot-area='screencapture -s -c'
alias screenshot-window='screencapture -w -c'

# Network utilities
alias localip="ipconfig getifaddr en0"
alias publicip="curl -s https://ipecho.net/plain && echo"
alias netstat='lsof -i'

# Development tools shortcuts
alias xcode='open -a Xcode'
alias simulator='open -a Simulator'
alias finder='open -a Finder'

# macOS-specific functions
ios-simulator() {
    local device="${1:-iPhone 14}"
    xcrun simctl boot "$device" && open -a Simulator
}

ios-logs() {
    local device="${1:-booted}"
    xcrun simctl spawn "$device" log stream --level debug
}

macos-info() {
    echo "🍎 macOS System Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Version: $(sw_vers -productVersion)"
    echo "Build: $(sw_vers -buildVersion)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo "Memory: $(vm_stat | head -1)"
    echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5" used)"}')"
    
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew: $(brew --version | head -1)"
        echo "Packages: $(brew list | wc -l | tr -d ' ') installed"
    fi
}

# Homebrew bundle management
brew-save() {
    echo "📦 Saving Homebrew bundle..."
    brew bundle dump --file="$HOMEBREW_BUNDLE_FILE" --force
    echo "✅ Bundle saved to $HOMEBREW_BUNDLE_FILE"
}

brew-install() {
    echo "📦 Installing from Homebrew bundle..."
    if [[ -f "$HOMEBREW_BUNDLE_FILE" ]]; then
        brew bundle install --file="$HOMEBREW_BUNDLE_FILE"
        echo "✅ Bundle installation complete"
    else
        echo "❌ Bundle file not found: $HOMEBREW_BUNDLE_FILE"
    fi
}

# Spotlight management
spotlight-off() {
    sudo mdutil -a -i off
    echo "🔍 Spotlight indexing disabled"
}

spotlight-on() {
    sudo mdutil -a -i on
    echo "🔍 Spotlight indexing enabled"
}

spotlight-rebuild() {
    sudo mdutil -E /
    echo "🔍 Spotlight index rebuilding..."
}

# macOS maintenance
macos-cleanup() {
    echo "🧹 Running macOS cleanup..."
    
    # Clear system caches
    echo "Clearing system caches..."
    sudo rm -rf /System/Library/Caches/*
    sudo rm -rf /Library/Caches/*
    rm -rf ~/Library/Caches/*
    
    # Clear download history
    echo "Clearing download history..."
    sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'
    
    # Clear DNS cache
    echo "Flushing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    
    # Empty trash
    echo "Emptying trash..."
    rm -rf ~/.Trash/*
    
    # Clear Homebrew cache
    if command -v brew >/dev/null 2>&1; then
        echo "Cleaning Homebrew..."
        brew cleanup -s
        brew autoremove
    fi
    
    echo "✅ macOS cleanup complete"
}

# App Store command line interface
app-store() {
    local command="$1"
    shift
    
    case "$command" in
        search)
            mas search "$@"
            ;;
        install)
            mas install "$@"
            ;;
        list)
            mas list
            ;;
        upgrade)
            mas upgrade
            ;;
        *)
            echo "Usage: app-store {search|install|list|upgrade} [args]"
            ;;
    esac
}

# Quick Look from command line
ql() {
    qlmanage -p "$@" >&/dev/null
}

# Notification from command line
notify() {
    local title="${1:-Notification}"
    local message="${2:-Task completed}"
    osascript -e "display notification \"$message\" with title \"$title\""
}

# Lock screen
lock() {
    /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
}

# macOS security functions
security-scan() {
    echo "🔒 macOS Security Scan"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check SIP status
    echo "System Integrity Protection: $(csrutil status)"
    
    # Check Gatekeeper
    echo "Gatekeeper: $(spctl --status)"
    
    # Check Firewall
    local firewall_status=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | awk '{print $3}')
    echo "Firewall: $firewall_status"
    
    # Check FileVault
    local filevault_status=$(fdesetup status | head -1)
    echo "FileVault: $filevault_status"
    
    # Check for unsigned apps
    echo "Checking for unsigned applications..."
    find /Applications -name "*.app" -exec codesign -dv {} \; 2>&1 | grep "not signed" | head -5
}

# Development environment helpers
xcode-select-reset() {
    sudo xcode-select --reset
    echo "🔧 Xcode command line tools reset"
}

ios-device-logs() {
    if command -v idevicesyslog >/dev/null 2>&1; then
        idevicesyslog
    else
        echo "Install libimobiledevice: brew install libimobiledevice"
    fi
}

# macOS-specific PATH additions
export PATH="/System/Cryptexes/App/usr/bin:$PATH"

# Python path for macOS
if [[ -d "/Library/Frameworks/Python.framework/Versions/Current/bin" ]]; then
    export PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH"
fi

# Ruby path for macOS (avoid system Ruby)
if [[ -d "$HOMEBREW_PREFIX/opt/ruby/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
    export PATH="$(gem environment gemdir)/bin:$PATH"
fi

# Go path
if [[ -d "$HOMEBREW_PREFIX/opt/go/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/go/bin:$PATH"
fi

# Java path
if [[ -d "$HOMEBREW_PREFIX/opt/openjdk/bin" ]]; then
    export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
fi

# macOS-specific completions
if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# Load macOS-specific tools
if command -v brew >/dev/null 2>&1; then
    # Enable Homebrew command completion
    eval "$(brew shellenv)"
fi

# iTerm2 integration
if [[ -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    source "$HOME/.iterm2_shell_integration.zsh"
fi

# macOS-specific environment optimizations
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES  # Fix for Python multiprocessing
export PYTHONDONTWRITEBYTECODE=1  # Prevent .pyc files

# Export macOS-specific functions
export -f ios-simulator ios-logs macos-info brew-save brew-install
export -f spotlight-off spotlight-on spotlight-rebuild macos-cleanup
export -f app-store ql notify lock security-scan xcode-select-reset ios-device-logs