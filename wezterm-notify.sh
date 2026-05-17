#!/usr/bin/env bash
# WezTerm notification hook for Claude Code
# Click notification → activate WezTerm + focus pane

set -euo pipefail

input=$(cat)

msg=$(echo "$input" | jq -r '.last_assistant_message // .message // empty')
n_type=$(echo "$input" | jq -r '.hook_event_name // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
cwd_last=$(echo "$cwd" | awk -F'/' '{print $NF}')
pane_id="${WEZTERM_PANE:-}"

title="Claude[${cwd_last:-Code}]"
body=""

case "$n_type" in
  PermissionRequest)
    tool=$(echo "$input" | jq -r '.tool_name // empty')
    title="Claude[${cwd_last}]: 需要确认"
    case "$tool" in
      Bash)
        cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
        desc=$(echo "$input" | jq -r '.tool_input.description // empty')
        param="${desc:-${cmd:-等待确认}}"
        body="➡️ [${tool}]: ${param}"
        ;;
      Write|Edit|Read)
        fp=$(echo "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
        body="📝 [${tool}]: ${fp}"
        ;;
      *)
        body="⚙️ [${tool}]"
        ;;
    esac
    ;;
  Stop)
    if [ -n "$msg" ]; then
      title="Claude[${cwd_last}]: 任务已完成"
      body="✅ ${msg}"
    else
      title="Claude[${cwd_last}]: 等待输入"
      body="💬 Claude 正在等待你的输入"
    fi
    ;;
  *)
    [ -n "$msg" ] && body="💡 ${msg}"
    ;;
esac

[ -z "$body" ] && body="任务已完成"

# Click action: activate WezTerm + focus pane
WEZTERM_BIN="$(command -v wezterm 2>/dev/null || echo /opt/homebrew/bin/wezterm)"
activate_cmd="osascript -e 'tell application id \"com.github.wez.wezterm\" to activate' && sleep 0.2 && ${WEZTERM_BIN} cli activate-pane --pane-id ${pane_id}"

terminal-notifier \
  -title "$title" \
  -message "$body" \
  -activate com.github.wez.wezterm \
  -execute "$activate_cmd" \
  -sound Glass
