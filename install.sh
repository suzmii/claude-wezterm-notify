#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_CMD="bash ~/.claude/wezterm-notify.sh"

echo "Installing claude-wezterm-notify..."

# Copy script
cp "$SCRIPT_DIR/wezterm-notify.sh" "$CLAUDE_DIR/wezterm-notify.sh"
echo "✓ Copied wezterm-notify.sh to $CLAUDE_DIR"

# Check dependencies
if ! command -v terminal-notifier &>/dev/null; then
  echo "✗ terminal-notifier not found. Install with: brew install terminal-notifier"
  exit 1
fi
echo "✓ terminal-notifier found"

if ! command -v jq &>/dev/null; then
  echo "✗ jq not found. Install with: brew install jq"
  exit 1
fi
echo "✓ jq found"

if ! command -v wezterm &>/dev/null; then
  echo "⚠ wezterm not found in PATH. Notifications will work but click-to-focus won't."
fi

# Ensure settings.json exists
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Add hooks to settings.json (append, not replace)
HOOK_ENTRY='{
  "hooks": [
    {
      "type": "command",
      "command": "'"$HOOK_CMD"'",
      "timeout": 10
    }
  ]
}'

tmp=$(mktemp)
jq --argjson entry "$HOOK_ENTRY" '
  .hooks = (.hooks // {}) |
  .hooks.PermissionRequest = ((.hooks.PermissionRequest // []) + [$entry] | unique_by(.hooks[0].command)) |
  .hooks.Stop = ((.hooks.Stop // []) + [$entry] | unique_by(.hooks[0].command))
' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
echo "✓ Hooks added to $SETTINGS"

echo ""
echo "Installation complete! Restart Claude Code to activate notifications."
