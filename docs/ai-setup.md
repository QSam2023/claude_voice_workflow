# AI 自动化配置指南 / AI Setup Guide

> 供 Claude Code 与其他 AI coding agent 自动完成配置

## 目标 / Goal

- 中文：为 AI 提供可执行步骤，自动完成 Claude Code 通知与安全配置。
- English: Provide executable steps for agents to configure Claude Code notifications and safety hooks.

## 适用范围 / Scope

- 中文：适用于本仓库的语音通知工作流部署。
- English: Applies to this repo’s voice notification workflow setup.

## 前置条件 / Prerequisites

- macOS 10.10+
- Homebrew 可用
- Claude Code 已安装
- 允许写入 `~/.claude`

## 配置步骤 / Setup Steps

### 步骤 1：安装通知工具 / Step 1: Install notifier

```bash
brew install terminal-notifier
terminal-notifier -message "测试" -title "测试"
```

### 步骤 2：确认 notify.sh / Step 2: Validate notify.sh

中文：`notify.sh` 应位于 `~/.claude/scripts/notify.sh`。若缺失，请先向用户确认脚本来源，再继续自动配置。
English: `notify.sh` should exist at `~/.claude/scripts/notify.sh`. If missing, confirm the source with the user before proceeding.

```bash
ls -la ~/.claude/scripts/notify.sh
chmod +x ~/.claude/scripts/notify.sh
```

### 步骤 3：配置 Hookify 规则 / Step 3: Hookify rules

中文：在 `~/.claude/` 下创建以下规则文件（若已存在则跳过）。
English: Create the following rule files under `~/.claude/` (skip if already present).

`~/.claude/hookify.voice-safety-rm.local.md`
```markdown
---
name: voice-safety-rm
enabled: true
event: bash
pattern: rm\s+(-rf|-fr)
action: block
---

语音安全：阻止危险的删除命令。
```

`~/.claude/hookify.voice-safety-git.local.md`
```markdown
---
name: voice-safety-git
enabled: true
event: bash
pattern: git\s+push.*--force
action: block
---

语音安全：阻止强制 Git 操作。
```

`~/.claude/hookify.voice-safety-env.local.md`
```markdown
---
name: voice-safety-env
enabled: true
event: bash
pattern: git\s+(add|commit).*\.env
action: warn
---

语音安全：检测到敏感文件操作。
```

### 步骤 4：配置 settings.json / Step 4: Configure settings.json

中文：编辑 `~/.claude/settings.json`，合并或追加 hooks 配置（避免覆盖用户已有配置）。
English: Edit `~/.claude/settings.json` and merge the hooks (do not overwrite existing user config).

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify.sh '✅ 任务完成' 'Claude Code 任务已成功完成' '' 'stop'",
            "timeout": 10
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify.sh '🔔 需要您的输入' 'Claude 正在等待您的响应，请回到终端' '需要输入，请回到终端' 'input'",
            "timeout": 15
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "bash",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -n \"$CLAUDE_TOOL_EXIT_CODE\" ] && [ \"$CLAUDE_TOOL_EXIT_CODE\" != \"0\" ]; then ~/.claude/scripts/notify.sh '❌ Bash 命令失败' \"退出码: $CLAUDE_TOOL_EXIT_CODE\" 'Bash 命令执行失败' 'error'; fi",
            "timeout": 10
          }
        ]
      }
    ],
    "Error": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify.sh '❌ 系统错误' 'Claude Code 遇到内部错误' '系统错误' 'error'",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

### 步骤 5：重启 Claude Code / Step 5: Restart

```bash
exit
claude
```

## 验证步骤 / Validation

```bash
~/.claude/scripts/notify.sh '✅ 测试' '任务完成' '' 'stop'
~/.claude/scripts/notify.sh '🔔 测试' '需要输入' '请回来' 'input'
~/.claude/scripts/notify.sh '❌ 测试' '任务失败' '出错了' 'error'
```

如需完整验证：执行 `./run_tests.sh`（会触发通知与语音）。

## 自动化注意事项 / Automation Notes

- 中文：运行时资产必须写入 `~/.claude`，不要写入仓库。
- English: Runtime assets must live under `~/.claude`, not inside the repo.
- 中文：如发现现有 hooks，需合并而非覆盖。
- English: Merge with existing hooks instead of overwriting.

## 机器可读附录 / Machine-Readable Appendix

```json
{
  "version": "1.0",
  "platform": "macOS",
  "requires": ["homebrew", "claude_code"],
  "paths": {
    "notify_script": "~/.claude/scripts/notify.sh",
    "settings": "~/.claude/settings.json",
    "hookify_rules": "~/.claude"
  },
  "steps": [
    {
      "id": "install_notifier",
      "type": "command",
      "description": "Install terminal-notifier and smoke test",
      "commands": [
        "brew install terminal-notifier",
        "terminal-notifier -message \"测试\" -title \"测试\""
      ]
    },
    {
      "id": "validate_notify_script",
      "type": "command",
      "description": "Ensure notify.sh exists and is executable",
      "commands": [
        "ls -la ~/.claude/scripts/notify.sh",
        "chmod +x ~/.claude/scripts/notify.sh"
      ]
    },
    {
      "id": "install_hookify_rules",
      "type": "file",
      "description": "Create Hookify rule files if missing",
      "files": [
        {
          "path": "~/.claude/hookify.voice-safety-rm.local.md",
          "mode": "0644",
          "skip_if_exists": true,
          "content": "---\nname: voice-safety-rm\nenabled: true\nevent: bash\npattern: rm\\s+(-rf|-fr)\naction: block\n---\n\n语音安全：阻止危险的删除命令。\n"
        },
        {
          "path": "~/.claude/hookify.voice-safety-git.local.md",
          "mode": "0644",
          "skip_if_exists": true,
          "content": "---\nname: voice-safety-git\nenabled: true\nevent: bash\npattern: git\\s+push.*--force\naction: block\n---\n\n语音安全：阻止强制 Git 操作。\n"
        },
        {
          "path": "~/.claude/hookify.voice-safety-env.local.md",
          "mode": "0644",
          "skip_if_exists": true,
          "content": "---\nname: voice-safety-env\nenabled: true\nevent: bash\npattern: git\\s+(add|commit).*\\.env\naction: warn\n---\n\n语音安全：检测到敏感文件操作。\n"
        }
      ]
    },
    {
      "id": "merge_settings",
      "type": "json_merge",
      "description": "Merge hooks into ~/.claude/settings.json",
      "target": "~/.claude/settings.json",
      "merge_key": "hooks",
      "payload": {
        "Stop": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/scripts/notify.sh '✅ 任务完成' 'Claude Code 任务已成功完成' '' 'stop'",
                "timeout": 10
              }
            ]
          }
        ],
        "Notification": [
          {
            "matcher": "permission_prompt|idle_prompt",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/scripts/notify.sh '🔔 需要您的输入' 'Claude 正在等待您的响应，请回到终端' '需要输入，请回到终端' 'input'",
                "timeout": 15
              }
            ]
          }
        ],
        "PostToolUse": [
          {
            "matcher": "bash",
            "hooks": [
              {
                "type": "command",
                "command": "if [ -n \"$CLAUDE_TOOL_EXIT_CODE\" ] && [ \"$CLAUDE_TOOL_EXIT_CODE\" != \"0\" ]; then ~/.claude/scripts/notify.sh '❌ Bash 命令失败' \"退出码: $CLAUDE_TOOL_EXIT_CODE\" 'Bash 命令执行失败' 'error'; fi",
                "timeout": 10
              }
            ]
          }
        ],
        "Error": [
          {
            "matcher": "",
            "hooks": [
              {
                "type": "command",
                "command": "~/.claude/scripts/notify.sh '❌ 系统错误' 'Claude Code 遇到内部错误' '系统错误' 'error'",
                "timeout": 15
              }
            ]
          }
        ]
      }
    },
    {
      "id": "restart_claude",
      "type": "command",
      "description": "Restart Claude Code",
      "commands": ["exit", "claude"]
    }
  ],
  "validation": [
    "~/.claude/scripts/notify.sh '✅ 测试' '任务完成' '' 'stop'",
    "~/.claude/scripts/notify.sh '🔔 测试' '需要输入' '请回来' 'input'",
    "~/.claude/scripts/notify.sh '❌ 测试' '任务失败' '出错了' 'error'"
  ]
}
```

## YAML 附录 / YAML Appendix

```yaml
version: "1.0"
platform: "macOS"
requires:
  - homebrew
  - claude_code
paths:
  notify_script: "~/.claude/scripts/notify.sh"
  settings: "~/.claude/settings.json"
  hookify_rules: "~/.claude"
steps:
  - id: install_notifier
    type: command
    description: Install terminal-notifier and smoke test
    commands:
      - brew install terminal-notifier
      - terminal-notifier -message "测试" -title "测试"
  - id: validate_notify_script
    type: command
    description: Ensure notify.sh exists and is executable
    commands:
      - ls -la ~/.claude/scripts/notify.sh
      - chmod +x ~/.claude/scripts/notify.sh
  - id: install_hookify_rules
    type: file
    description: Create Hookify rule files if missing
    files:
      - path: "~/.claude/hookify.voice-safety-rm.local.md"
        mode: "0644"
        skip_if_exists: true
        content: |
          ---
          name: voice-safety-rm
          enabled: true
          event: bash
          pattern: rm\s+(-rf|-fr)
          action: block
          ---

          语音安全：阻止危险的删除命令。
      - path: "~/.claude/hookify.voice-safety-git.local.md"
        mode: "0644"
        skip_if_exists: true
        content: |
          ---
          name: voice-safety-git
          enabled: true
          event: bash
          pattern: git\s+push.*--force
          action: block
          ---

          语音安全：阻止强制 Git 操作。
      - path: "~/.claude/hookify.voice-safety-env.local.md"
        mode: "0644"
        skip_if_exists: true
        content: |
          ---
          name: voice-safety-env
          enabled: true
          event: bash
          pattern: git\s+(add|commit).*\.env
          action: warn
          ---

          语音安全：检测到敏感文件操作。
  - id: merge_settings
    type: json_merge
    description: Merge hooks into ~/.claude/settings.json
    target: "~/.claude/settings.json"
    merge_key: "hooks"
    payload:
      Stop:
        - matcher: ""
          hooks:
            - type: command
              command: "~/.claude/scripts/notify.sh '✅ 任务完成' 'Claude Code 任务已成功完成' '' 'stop'"
              timeout: 10
      Notification:
        - matcher: "permission_prompt|idle_prompt"
          hooks:
            - type: command
              command: "~/.claude/scripts/notify.sh '🔔 需要您的输入' 'Claude 正在等待您的响应，请回到终端' '需要输入，请回到终端' 'input'"
              timeout: 15
      PostToolUse:
        - matcher: "bash"
          hooks:
            - type: command
              command: "if [ -n \"$CLAUDE_TOOL_EXIT_CODE\" ] && [ \"$CLAUDE_TOOL_EXIT_CODE\" != \"0\" ]; then ~/.claude/scripts/notify.sh '❌ Bash 命令失败' \"退出码: $CLAUDE_TOOL_EXIT_CODE\" 'Bash 命令执行失败' 'error'; fi"
              timeout: 10
      Error:
        - matcher: ""
          hooks:
            - type: command
              command: "~/.claude/scripts/notify.sh '❌ 系统错误' 'Claude Code 遇到内部错误' '系统错误' 'error'"
              timeout: 15
  - id: restart_claude
    type: command
    description: Restart Claude Code
    commands:
      - exit
      - claude
validation:
  - "~/.claude/scripts/notify.sh '✅ 测试' '任务完成' '' 'stop'"
  - "~/.claude/scripts/notify.sh '🔔 测试' '需要输入' '请回来' 'input'"
  - "~/.claude/scripts/notify.sh '❌ 测试' '任务失败' '出错了' 'error'"
```

## 相关文档 / Related Docs

- `docs/QUICK-START.md`
- `docs/README-实施指南.md`
- `docs/TEST-CASES.md`
- `docs/index.md`

## End
