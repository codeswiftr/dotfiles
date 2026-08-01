# Optional fleet profile shell extras.
# Enable with:  touch config/profiles/fleet/.enabled
#           or: export DOTFILES_PROFILE=fleet
# Secrets stay in ~/.env.local (never commit).

# OpenClaw completion + node relay helper
[[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && \
    source "$HOME/.openclaw/completions/openclaw.zsh"

# claw-relay: set OPENCLAW_GATEWAY_TOKEN and OPENCLAW_RELAY_HOST in ~/.env.local
if [[ -n "${OPENCLAW_GATEWAY_TOKEN:-}" && -n "${OPENCLAW_RELAY_HOST:-}" ]]; then
    alias claw-relay='openclaw node run --host "$OPENCLAW_RELAY_HOST" --port 443 --tls --display-name "${OPENCLAW_DISPLAY_NAME:-my-node}"'
fi
