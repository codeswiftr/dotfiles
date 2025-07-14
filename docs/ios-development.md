# 🍎 iOS & SwiftUI Development Guide

Complete guide to iOS and SwiftUI development with the dotfiles environment.

## 🚀 Quick Start

```bash
# Initialize a new iOS project
ios-init MyAwesomeApp

# Build the project
ios-quick-build

# Start the iOS Simulator
ios-simulator-start

# Run tests
ios-test-run
```

## 📱 Project Management

### Creating New Projects

```bash
# Create iOS app with SwiftUI
ios-init MyApp

# Create Swift package
swift-package-init MyLibrary

# Create iOS project with specific template
ios-init MyApp --template=tabbed
```

### Building and Testing

```bash
# Quick build for current project
ios-quick-build

# Build specific scheme
ios-quick-build MyApp

# Run unit tests
ios-test-run

# Run UI tests
ios-ui-test-run

# Run tests with coverage
ios-test-coverage
```

## 🔧 Development Tools

### Code Formatting

```bash
# Format Swift code in current directory
swift-format .

# Format specific files
swift-format Sources/MyApp/ContentView.swift

# Check formatting without applying changes
swift-format --lint .
```

### Device Management

```bash
# List available simulators
ios-devices

# List physical devices
ios-devices --physical

# View device logs
ios-logs

# Install app on device
ios-install MyApp.app
```

### Package Management

```bash
# Add Swift package dependency
swift-package-add https://github.com/pointfreeco/swift-composable-architecture

# Update packages
swift-package-update

# Generate Package.swift
swift-package-generate
```

## 🖥️ Xcode Integration

### Opening Projects

```bash
# Open current directory in Xcode
xcode .

# Open specific project
xcode MyApp.xcodeproj

# Open workspace
xcode MyApp.xcworkspace
```

### Build Tools

```bash
# Clean build folder
xcode-clean

# Build for device
xcode-build-device

# Archive for distribution
xcode-archive MyApp
```

## 📲 Simulator Management

### Starting Simulators

```bash
# Start default simulator
ios-simulator-start

# Start specific device
ios-simulator-start "iPhone 15 Pro"

# Start with specific iOS version
ios-simulator-start "iPhone 15 Pro" "17.0"
```

### Simulator Operations

```bash
# Reset simulator
ios-simulator-reset

# Take screenshot
ios-simulator-screenshot

# Record video
ios-simulator-record MyApp-demo.mp4
```

## 🔍 Debugging Tools

### Logging and Diagnostics

```bash
# View real-time logs
ios-logs --follow

# Filter logs by app
ios-logs --app MyApp

# View crash logs
ios-crash-logs

# Analyze memory usage
ios-memory-analyze MyApp
```

### Performance Tools

```bash
# Profile app performance
ios-profile MyApp

# Measure app launch time
ios-launch-time MyApp

# Memory leak detection
ios-leaks MyApp
```

## 🎨 Asset Management

### Image Assets

```bash
# Generate app icons from single image
ios-generate-icons icon.png

# Optimize images for iOS
ios-optimize-images Assets.xcassets

# Convert to HEIC format
ios-convert-heic *.jpg
```

### Localization

```bash
# Extract localizable strings
ios-extract-strings

# Generate localization files
ios-generate-localizations

# Validate translations
ios-validate-localizations
```

## ⚙️ Configuration

### Xcode Settings

The iOS development environment automatically configures:

- Swift formatting settings
- Build configurations for Debug/Release
- Code signing settings
- Simulator preferences

### Custom Configuration

Create `~/.ios-dev-config` to customize settings:

```bash
# Default simulator device
SIMULATOR_DEVICE="iPhone 15 Pro"

# Default iOS version
SIMULATOR_IOS_VERSION="17.0"

# Code signing identity
CODE_SIGN_IDENTITY="Apple Development"

# Development team ID
DEVELOPMENT_TEAM="ABC123DEF4"
```

## 🏗️ Specialized Tmux Layout

Access the iOS development layout with:

```bash
# From tmux command palette
Ctrl-a D → iOS Development

# Or directly
tmux-ios-layout
```

The layout provides:

1. **Main Editor Pane** - For Xcode or text editor
2. **Build Output** - Shows build logs and errors  
3. **Simulator Control** - Manage simulator and devices
4. **File Management** - Navigate project files

## 📋 Common Workflows

### New Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/awesome-feature

# 2. Open in Xcode
xcode .

# 3. Start simulator
ios-simulator-start

# 4. Make changes and test
ios-quick-build && ios-test-run

# 5. Format code
swift-format .

# 6. Commit changes
git add . && git commit -m "feat: Add awesome feature"
```

### App Store Submission

```bash
# 1. Increment version
ios-increment-version

# 2. Archive for distribution
xcode-archive MyApp

# 3. Validate archive
ios-validate-archive

# 4. Upload to App Store Connect
ios-upload-archive
```

### Continuous Integration

```bash
# CI-friendly build command
ios-ci-build

# Generate test reports
ios-test-report --junit

# Code coverage for CI
ios-coverage-report --xml
```

## 🔗 Integration with Other Tools

### Git Hooks

Automatically format Swift code on commit:

```bash
# Enable pre-commit formatting
ios-enable-git-hooks

# Disable formatting hook
ios-disable-git-hooks
```

### AI Code Review

```bash
# AI-powered code review
ai ios-review

# Generate documentation
ai ios-docs

# Code suggestions
ai ios-suggest
```

## ⚠️ Troubleshooting

### Common Issues

**Simulator not starting:**
```bash
# Reset simulator data
ios-simulator-reset

# Restart simulator service
sudo killall -9 com.apple.CoreSimulator.CoreSimulatorService
```

**Build failures:**
```bash
# Clean derived data
xcode-clean-derived-data

# Reset package cache
swift-package-reset-cache

# Check code signing
ios-check-codesign
```

**Device connectivity:**
```bash
# Reset device trust
ios-reset-device-trust

# Check provisioning profiles
ios-check-profiles

# Refresh devices
ios-refresh-devices
```

### Performance Issues

**Slow builds:**
```bash
# Enable build timing
xcode-enable-build-timing

# Analyze build times
ios-build-analysis

# Optimize project settings
ios-optimize-build-settings
```

## 📚 Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)
- [iOS App Store Guidelines](https://developer.apple.com/app-store/guidelines/)

## 🤝 Contributing

If you find issues or want to add new iOS development tools:

1. Create an issue describing the problem/enhancement
2. Fork the repository
3. Add your iOS tools to `config/zsh/ios-swift.zsh`
4. Test thoroughly with different iOS projects
5. Submit a pull request with clear documentation

---

Ready to build amazing iOS apps! 🚀📱