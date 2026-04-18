# Managed by dotfiles — do not edit directly
# Login shell setup — runs once per login session

# Homebrew (platform-aware)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
