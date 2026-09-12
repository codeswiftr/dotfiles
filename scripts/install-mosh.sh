#!/usr/bin/env bash
# Install mosh-server for Moshi / phone remotes.
# Prefer package managers; fall back to a static binary in ~/.local/bin (no root).
set -euo pipefail

if command -v mosh-server >/dev/null 2>&1; then
  echo "mosh-server already available: $(command -v mosh-server)"
  exit 0
fi

if [[ -x "$HOME/.local/bin/mosh-server" ]]; then
  echo "mosh-server already at $HOME/.local/bin/mosh-server"
  exit 0
fi

install_static_linux() {
  local arch asset url
  case "$(uname -m)" in
    x86_64|amd64) asset="mosh-server-1.4.0+blink-18.4.5-linux-amd64" ;;
    aarch64|arm64) asset="mosh-server-1.4.0+blink-18.4.5-linux-arm64" ;;
    *)
      echo "No static mosh-server for arch=$(uname -m); install mosh via your package manager" >&2
      return 1
      ;;
  esac
  # Tag and asset name contain '+'; URL-encode it.
  url="https://github.com/blinksh/mosh-static-multiarch/releases/download/1.4.0%2Bblink-18.4.5/${asset//+/%2B}"
  mkdir -p "$HOME/.local/bin"
  local tmp
  tmp="$(mktemp)"
  curl -fsSL "$url" -o "$tmp"
  chmod 755 "$tmp"
  mv -f "$tmp" "$HOME/.local/bin/mosh-server"
  echo "Installed static mosh-server → $HOME/.local/bin/mosh-server"
}

os="$(uname -s)"
case "$os" in
  Darwin)
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew required to install mosh on macOS" >&2
      exit 1
    fi
    brew install mosh
    ;;
  Linux)
    if command -v apt-get >/dev/null 2>&1; then
      if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        sudo apt-get update -qq
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mosh
      elif [[ "${EUID:-1}" -eq 0 ]]; then
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y mosh
      else
        echo "No passwordless sudo — installing static mosh-server to ~/.local/bin"
        install_static_linux
      fi
    elif command -v pacman >/dev/null 2>&1; then
      if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
        sudo pacman -S --noconfirm mosh
      elif [[ "${EUID:-1}" -eq 0 ]]; then
        pacman -S --noconfirm mosh
      else
        install_static_linux
      fi
    elif command -v apk >/dev/null 2>&1; then
      apk add --no-cache mosh || install_static_linux
    else
      install_static_linux
    fi
    ;;
  *)
    echo "Unsupported OS for mosh install: $os" >&2
    exit 1
    ;;
esac

if command -v mosh-server >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/mosh-server" ]]; then
  echo "mosh-server ready: $(command -v mosh-server 2>/dev/null || echo "$HOME/.local/bin/mosh-server")"
  exit 0
fi

echo "mosh-server install finished but binary not found on PATH" >&2
exit 1
