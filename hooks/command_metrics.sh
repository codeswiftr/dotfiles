#!/usr/bin/env bash
# Metrics collection hook for command execution

if [[ "${METRICS_ENABLED:-true}" == "true" ]]; then
    source "$DOTFILES_DIR/lib/metrics.sh"
    collect_command_metrics "$@"
fi
