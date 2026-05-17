# Claude WezTerm Notify

Claude Code 的 WezTerm 终端通知钩子。当 Claude 需要确认操作或完成任务时，通过 macOS 系统通知提醒你。

## 通知样式

- ➡️ Bash 命令执行
- 📝 文件读写操作（Write/Edit/Read）
- ⚙️ 其他工具
- ✅ 任务完成
- 💬 等待用户输入

## 依赖

- macOS
- [WezTerm](https://wezfurlong.org/wezterm/) 终端
- [terminal-notifier](https://github.com/julienXX/terminal-notifier)：`brew install terminal-notifier`
- jq（macOS 自带）

## 安装

1. 复制脚本到 Claude 配置目录：

```bash
cp wezterm-notify.sh ~/.claude/wezterm-notify.sh
```

2. 在 `~/.claude/settings.json` 中添加 hooks：

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/wezterm-notify.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/wezterm-notify.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

3. 确保 WezTerm 设置了 `WEZTERM_PANE` 环境变量（默认已启用）。

## 点击通知

点击通知会自动激活 WezTerm 窗口并聚焦到触发通知的面板。

## 卸载

```bash
./uninstall.sh
```

会移除脚本和 settings.json 中的 hook 配置，不影响其他 hooks。

## License

MIT
