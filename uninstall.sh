#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_CMD="bash ~/.claude/wezterm-notify.sh"

echo "Uninstalling claude-wezterm-notify..."

# Remove script
if [ -f "$CLAUDE_DIR/wezterm-notify.sh" ]; then
  rm "$CLAUDE_DIR/wezterm-notify.sh"
  echo "✓ Removed wezterm-notify.sh"
else
  echo "- wezterm-notify.sh not found, skipping"
fi

# Remove hook entries from settings.json
if [ -f "$SETTINGS" ]; then
  tmp=$(mktemp)
  jq --arg cmd "$HOOK_CMD" '
    .hooks.PermissionRequest = [(.hooks.PermissionRequest // [])[] | select(.hooks[0].command != $cmd)] |
    .hooks.Stop = [(.hooks.Stop // [])[] | select(.hooks[0].command != $cmd)] |
    if (.hooks.PermissionRequest // []) == [] then del(.hooks.PermissionRequest) else . end |
    if (.hooks.Stop // []) == [] then del(.hooks.Stop) else . end |
    if .hooks == {} then del(.hooks) else . end
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "✓ Removed hooks from $SETTINGS"
fi

echo ""
echo "Uninstall complete! Restart Claude Code to take effect."
