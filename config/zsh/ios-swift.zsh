# ============================================================================
# iOS and SwiftUI Development Configuration
# Enhanced tooling for iOS app development workflow
# ============================================================================

# Xcode and iOS Simulator aliases
alias xcode="open -a Xcode"
alias xcodeproj="open *.xcodeproj"
alias xcodeworkspace="open *.xcworkspace"
alias simulator="open -a Simulator"
alias ios-sim="xcrun simctl"

# iOS Simulator management
alias ios-list="xcrun simctl list devices"
alias ios-boot="xcrun simctl boot"
alias ios-shutdown="xcrun simctl shutdown"
alias ios-erase="xcrun simctl erase"
alias ios-install="xcrun simctl install booted"
alias ios-uninstall="xcrun simctl uninstall booted"
alias ios-launch="xcrun simctl launch booted"
alias ios-screenshot="xcrun simctl io booted screenshot"
alias ios-record="xcrun simctl io booted recordVideo"

# Swift Package Manager
alias swift-init="swift package init"
alias swift-build="swift build"
alias swift-test="swift test"
alias swift-run="swift run"
alias swift-clean="swift package clean"
alias swift-update="swift package update"
alias swift-resolve="swift package resolve"
alias swift-describe="swift package describe"

# Xcode build tools
alias xbuild="xcodebuild"
alias xtest="xcodebuild test"
alias xclean="xcodebuild clean"
alias xarchive="xcodebuild archive"
alias xanalyze="xcodebuild analyze"

# iOS Development shortcuts
alias ios-logs="xcrun simctl spawn booted log stream"
alias ios-syslog="tail -f /private/var/log/system.log"
alias ios-crash="open ~/Library/Logs/DiagnosticReports"

# SwiftUI Previews management
alias swiftui-preview="xcrun simctl boot 'iPhone 15 Pro' && open -a Xcode"
alias preview-device="xcrun simctl list devices | grep Booted"

# iOS build and deployment functions
ios-quick-build() {
    local scheme=${1:-$(ls *.xcodeproj | sed 's/\.xcodeproj//')}
    echo "🏗️  Building iOS app: $scheme"
    xcodebuild -scheme "$scheme" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
}

ios-quick-test() {
    local scheme=${1:-$(ls *.xcodeproj | sed 's/\.xcodeproj//')}
    echo "🧪 Testing iOS app: $scheme"
    xcodebuild -scheme "$scheme" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' test
}

ios-quick-run() {
    local scheme=${1:-$(ls *.xcodeproj | sed 's/\.xcodeproj//')}
    echo "🚀 Running iOS app: $scheme"
    ios-quick-build "$scheme" && ios-launch "$scheme"
}

# Device management helpers
ios-reset-simulator() {
    echo "🔄 Resetting iOS Simulator..."
    xcrun simctl shutdown all
    xcrun simctl erase all
    xcrun simctl boot 'iPhone 15 Pro'
    echo "✅ iOS Simulator reset complete"
}

ios-setup-development() {
    echo "🔧 Setting up iOS development environment..."
    
    # Boot preferred simulator
    xcrun simctl boot 'iPhone 15 Pro' 2>/dev/null || echo "Simulator already running"
    
    # Install common debugging tools
    command -v ios-deploy >/dev/null || echo "📱 Consider installing ios-deploy: brew install ios-deploy"
    command -v xcpretty >/dev/null || echo "🎨 Consider installing xcpretty: gem install xcpretty"
    
    echo "✅ iOS development environment ready"
}

# Auto-completion for iOS simulators
if command -v xcrun >/dev/null 2>&1; then
    # Cache iOS device list for faster completion
    _ios_devices_cache="/tmp/.ios_devices_$(whoami)"
    
    _refresh_ios_devices() {
        xcrun simctl list devices available | rg "iPhone|iPad" | sed 's/.*(\([^)]*\)).*/\1/' > "$_ios_devices_cache"
    }
    
    # Refresh cache if older than 1 hour
    if [[ ! -f "$_ios_devices_cache" ]] || [[ $(find "$_ios_devices_cache" -mmin +60 2>/dev/null) ]]; then
        _refresh_ios_devices
    fi
fi