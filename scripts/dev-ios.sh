#!/usr/bin/env bash

# iOS/SwiftUI development helper
set -euo pipefail

print_help() {
  cat <<'EOF'
Usage: dev-ios.sh <command> [args]

Commands:
  help            Show this help
  boot            Boot a default iOS simulator (if not already booted)
  open            Open Simulator app
  preview         Open Xcode for SwiftUI previews in current project
  build           Attempt to build current Xcode project/workspace

Environment hints:
  PROJECT_SCHEME   Xcode scheme to build
  PROJECT_SDK      iOS SDK (default: iphonesimulator)
  PROJECT_CONFIG   Build configuration (default: Debug)

Notes:
  - This helper is conservative; it prints guidance if project details are unknown.
  - It avoids destructive actions and exits successfully when guidance is shown.
EOF
}

cmd="${1:-help}"
shift || true

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "⚠️  Missing dependency: $1"
    return 1
  fi
}

list_projects() {
  rg --files -g "*.xcodeproj" -g "*.xcworkspace" 2>/dev/null || true
}

case "$cmd" in
  help|-h|--help)
    print_help; exit 0;
    ;;
  boot)
    if ! require xcrun; then
      echo "💡 Install Xcode command line tools first."; exit 0; fi
    # Try to boot a recent iPhone device if none is booted
    if xcrun simctl list devices booted | grep -q "Booted"; then
      echo "✅ Simulator already booted"; exit 0
    fi
    device=$(xcrun simctl list devices available | sed -n 's/.*(\(.*\)) (Shutdown)$/\1/p' | head -n1 || true)
    if [[ -n "$device" ]]; then
      xcrun simctl boot "$device" || true
      open -a Simulator || true
      echo "✅ Booted simulator: $device"
    else
      echo "⚠️  Could not find an available simulator. Open Simulator and create one."
    fi
    ;;
  open)
    open -a Simulator || { echo "⚠️  Could not open Simulator"; }
    ;;
  preview)
    # Open Xcode in current directory if a project is present
    projs=$(list_projects)
    if [[ -z "$projs" ]]; then
      echo "💡 No Xcode project/workspace found. Open your Swift package or Xcode project to use previews."
      exit 0
    fi
    # Open the first project/workspace found
    open "$(echo "$projs" | head -n1)"
    echo "ℹ️  Opened Xcode. Use Canvas previews in your SwiftUI files."
    ;;
  build)
    if ! require xcodebuild; then
      echo "💡 Install Xcode first."; exit 0; fi
    projs=$(list_projects)
    if [[ -z "$projs" ]]; then
      echo "💡 No Xcode project/workspace found to build."
      exit 0
    fi
    scheme="${PROJECT_SCHEME:-}"
    sdk="${PROJECT_SDK:-iphonesimulator}"
    config="${PROJECT_CONFIG:-Debug}"
    if [[ -z "$scheme" ]]; then
      printf "ℹ️  Detected projects:\n%s\n" "$projs"
      echo "💡 Set PROJECT_SCHEME to build a specific scheme, e.g.:"
      echo "   PROJECT_SCHEME=MyApp ./scripts/dev-ios.sh build"
      exit 0
    fi
    set -x
    xcodebuild -scheme "$scheme" -configuration "$config" -sdk "$sdk" build | xcpretty || true
    set +x
    ;;
  *)
    print_help; exit 0;
    ;;
esac
