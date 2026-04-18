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

# ============================================================================
# Swift Package Manager (SPM) Helpers
# ============================================================================

# Initialize a new Swift package
swift-package-init() {
    local package_name=${1:-"MyPackage"}
    local package_type=${2:-"library"}
    
    echo "📦 Creating Swift package: $package_name"
    
    case "$package_type" in
        "library"|"lib")
            swift package init --type library --name "$package_name"
            ;;
        "executable"|"exe"|"app")
            swift package init --type executable --name "$package_name"
            ;;
        "plugin")
            swift package init --type build-tool-plugin --name "$package_name"
            ;;
        *)
            echo "❓ Unknown package type: $package_type"
            echo "💡 Available types: library, executable, plugin"
            return 1
            ;;
    esac
    
    echo "✅ Swift package '$package_name' created successfully!"
    echo "💡 Run 'cd $package_name && swift build' to build"
}

# Add a Swift package dependency
swift-package-add() {
    local package_url="$1"
    local version_requirement="${2:-branch:main}"
    
    if [[ -z "$package_url" ]]; then
        echo "❌ Usage: swift-package-add <package-url> [version]"
        echo "💡 Example: swift-package-add https://github.com/pointfreeco/swift-composable-architecture"
        return 1
    fi
    
    # Extract package name from URL
    local package_name=$(basename "$package_url" .git)
    
    echo "📦 Adding Swift package dependency: $package_name"
    echo "🔗 URL: $package_url"
    echo "📋 Version: $version_requirement"
    
    # Check if Package.swift exists
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    # Backup Package.swift
    cp Package.swift Package.swift.backup
    
    # Add dependency to Package.swift (basic implementation)
    echo "⚠️  Please manually add the following to your Package.swift:"
    echo "   In dependencies array:"
    echo "   .package(url: \"$package_url\", $version_requirement)"
    echo ""
    echo "   In target dependencies:"
    echo "   \"$package_name\""
    echo ""
    echo "🔧 Run 'swift package resolve' after editing Package.swift"
}

# Update Swift package dependencies
swift-package-update() {
    echo "🔄 Updating Swift package dependencies..."
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    swift package update
    echo "✅ Dependencies updated!"
}

# Resolve Swift package dependencies
swift-package-resolve() {
    echo "🔍 Resolving Swift package dependencies..."
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    swift package resolve
    echo "✅ Dependencies resolved!"
}

# Show Swift package dependencies
swift-package-list() {
    echo "📋 Swift package dependencies:"
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    swift package show-dependencies
}

# Generate Xcode project from Swift package
swift-package-generate-xcodeproj() {
    echo "🔨 Generating Xcode project from Swift package..."
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    swift package generate-xcodeproj
    echo "✅ Xcode project generated!"
    
    # Try to open the generated project
    local project_name=$(basename "$PWD")
    if [[ -d "$project_name.xcodeproj" ]]; then
        echo "🚀 Opening Xcode project..."
        open "$project_name.xcodeproj"
    fi
}

# Clean Swift package build artifacts
swift-package-clean() {
    echo "🧹 Cleaning Swift package build artifacts..."
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found. Are you in a Swift package directory?"
        return 1
    fi
    
    swift package clean
    
    # Also remove .build directory and other artifacts
    [[ -d ".build" ]] && rm -rf .build && echo "  🗑️  Removed .build directory"
    [[ -d "Package.resolved" ]] && rm -f Package.resolved && echo "  🗑️  Removed Package.resolved"
    [[ -d "*.xcodeproj" ]] && rm -rf *.xcodeproj && echo "  🗑️  Removed Xcode project"
    
    echo "✅ Clean complete!"
}

# Reset Swift package dependencies (nuclear option)
swift-package-reset() {
    echo "⚠️  WARNING: This will reset all package dependencies!"
    echo "Are you sure? (y/N)"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "🔥 Resetting Swift package dependencies..."
        
        # Remove Package.resolved and .build
        [[ -f "Package.resolved" ]] && rm -f Package.resolved
        [[ -d ".build" ]] && rm -rf .build
        
        # Re-resolve dependencies
        swift package resolve
        
        echo "✅ Package dependencies reset!"
    else
        echo "🚫 Reset cancelled."
    fi
}

# Interactive Swift package dependency browser
swift-package-search() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        echo "🔍 Swift Package Search"
        echo "Usage: swift-package-search <search-term>"
        echo ""
        echo "💡 Popular Swift packages:"
        echo "  • Alamofire - HTTP networking library"
        echo "  • SwiftUI Navigation - Advanced SwiftUI navigation"
        echo "  • The Composable Architecture - App architecture library"
        echo "  • swift-argument-parser - Command-line argument parsing"
        echo "  • swift-log - Logging API"
        echo "  • swift-crypto - Cryptographic operations"
        return 0
    fi
    
    echo "🔍 Searching for Swift packages: $query"
    echo "🌐 Opening Swift Package Index..."
    
    # Open Swift Package Index search
    open "https://swiftpackageindex.com/search?query=$(echo "$query" | sed 's/ /%20/g')"
}

# Show Swift package status
swift-package-status() {
    echo "📊 Swift Package Status"
    echo "======================"
    
    if [[ ! -f "Package.swift" ]]; then
        echo "❌ No Package.swift found in current directory"
        echo "💡 Run 'swift-package-init' to create a new package"
        return 1
    fi
    
    echo "📦 Package found: $(basename "$PWD")"
    echo ""
    
    # Show Package.swift content
    echo "📋 Package.swift:"
    head -20 Package.swift | sed 's/^/  /'
    echo ""
    
    # Show dependencies if Package.resolved exists
    if [[ -f "Package.resolved" ]]; then
        echo "🔗 Resolved dependencies:"
        swift package show-dependencies 2>/dev/null | head -10 | sed 's/^/  /'
    else
        echo "🔗 No resolved dependencies (run 'swift package resolve')"
    fi
    echo ""
    
    # Show build status
    if [[ -d ".build" ]]; then
        echo "🔨 Build artifacts present"
        local build_size=$(du -sh .build 2>/dev/null | cut -f1)
        echo "  📁 Build directory size: $build_size"
    else
        echo "🔨 No build artifacts (run 'swift build')"
    fi
    echo ""
    
    echo "🛠️  Available commands:"
    echo "  swift-package-add <url>      Add dependency"
    echo "  swift-package-update         Update dependencies"
    echo "  swift-package-clean          Clean build artifacts"
    echo "  swift-package-generate-xcodeproj Generate Xcode project"
    echo "  swift-package-search <term>  Search packages online"
}

# ============================================================================
# iOS Testing Workflow Enhancement
# ============================================================================

# Run iOS tests with enhanced output
ios-test-run() {
    local scheme="${1:-}"
    local destination="${2:-platform=iOS Simulator,name=iPhone 15 Pro}"
    
    echo "🧪 Running iOS tests..."
    
    # Auto-detect scheme if not provided
    if [[ -z "$scheme" ]]; then
        # Look for .xcodeproj or .xcworkspace
        if ls *.xcworkspace >/dev/null 2>&1; then
            local workspace=$(ls *.xcworkspace | head -1)
            scheme=$(basename "$workspace" .xcworkspace)
            echo "📱 Auto-detected workspace scheme: $scheme"
            xcodebuild test -workspace "$workspace" -scheme "$scheme" -destination "$destination" | xcpretty
        elif ls *.xcodeproj >/dev/null 2>&1; then
            local project=$(ls *.xcodeproj | head -1)
            scheme=$(basename "$project" .xcodeproj)
            echo "📱 Auto-detected project scheme: $scheme"
            xcodebuild test -project "$project" -scheme "$scheme" -destination "$destination" | xcpretty
        else
            echo "❌ No Xcode project or workspace found"
            return 1
        fi
    else
        xcodebuild test -scheme "$scheme" -destination "$destination" | xcpretty
    fi
}

# Run UI tests specifically
ios-ui-test-run() {
    local scheme="${1:-}"
    local destination="${2:-platform=iOS Simulator,name=iPhone 15 Pro}"
    
    echo "🎭 Running iOS UI tests..."
    
    if [[ -z "$scheme" ]]; then
        # Look for UI test schemes
        local ui_scheme=$(xcodebuild -list 2>/dev/null | grep -i "uitest" | head -1 | xargs)
        if [[ -n "$ui_scheme" ]]; then
            scheme="$ui_scheme"
            echo "📱 Auto-detected UI test scheme: $scheme"
        else
            echo "❌ No UI test scheme found"
            return 1
        fi
    fi
    
    xcodebuild test -scheme "$scheme" -destination "$destination" -only-testing:"${scheme}UITests" | xcpretty
}

# Test coverage reporting
ios-test-coverage() {
    local scheme="${1:-}"
    local destination="${2:-platform=iOS Simulator,name=iPhone 15 Pro}"
    
    echo "📊 Running iOS tests with coverage..."
    
    if [[ -z "$scheme" ]]; then
        if ls *.xcodeproj >/dev/null 2>&1; then
            local project=$(ls *.xcodeproj | head -1)
            scheme=$(basename "$project" .xcodeproj)
        else
            echo "❌ No Xcode project found"
            return 1
        fi
    fi
    
    xcodebuild test -scheme "$scheme" -destination "$destination" -enableCodeCoverage YES | xcpretty
    
    echo "📈 Coverage report available in Xcode"
}

echo "🍎 iOS development environment loaded"
echo "💡 Key commands: ios-init, swift-package-init, ios-test-run, swift-package-status"