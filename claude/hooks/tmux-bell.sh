#!/usr/bin/env bash
# Claude Code Notification hook: emit BEL so tmux marks the window as alerted.
# Configured via ~/.claude/settings.json; installed by scripts/install.py.
#
# Claude Code only invokes this hook for notification-worthy events (permission
# prompts, idle prompts), so we don't filter by type — just ring the bell.
# That also keeps us resilient to payload-schema changes upstream.
set -euo pipefail

input="$(cat)"

# Optional payload logging for debugging. Enable with:
#   CLAUDE_HOOK_DEBUG=1
if [ -n "${CLAUDE_HOOK_DEBUG:-}" ]; then
  log="${HOME}/.claude/hooks/tmux-bell.log"
  printf '%s\t%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "${input//$'\n'/ }" >> "$log" 2>/dev/null || true
fi

if [ -w /dev/tty ]; then
  printf '\a' > /dev/tty
fi

exit 0
