# Claude Code 语音驱动 AI 编码工作流 - 实施指南

> 基于 Claude Code + Hookify 的多模态通知系统

**版本**: 2.2  
**更新日期**: 2026-01-20  
**适用平台**: macOS 10.10+

---

## 📋 目录

1. [项目概述](#项目概述)
2. [核心特性](#核心特性)
3. [架构设计](#架构设计)
4. [安装部署](#安装部署)
5. [配置详解](#配置详解)
6. [使用指南](#使用指南)
7. [故障排查](#故障排查)
8. [进阶定制](#进阶定制)

---

## 项目概述

### 设计目标

本项目提供一套完整的语音驱动 AI 编码工作流方案，通过整合：

- **语音输入**: Typeless / macOS Dictation
- **AI 编码**: Claude Code
- **通知系统**: 原生 Hooks + 多模态反馈
- **安全防护**: Hookify 规则引擎

### 核心价值

✅ **提升效率**: 语音输入速度是打字的 3-5 倍  
✅ **多任务能力**: 耗时任务无需监控，自动通知  
✅ **安全防护**: 语音输入时防止误解导致的危险操作  
✅ **智能反馈**: 根据事件类型自动选择通知方式

---

## 核心特性

### 🎯 三级通知系统

| 级别 | 触发条件 | 桌面通知 | 语音提示 | 提示音 | 语速 | 重复 |
|------|----------|----------|----------|--------|------|------|
| **Stop** | 任务完成 | ✅ | ❌ | Pop (轻柔) | - | 0 |
| **Input** | 需要输入 | ✅ | ✅ | Ping (清脆) | 180 | 1 |
| **Error** | 失败/错误 | ✅ | ✅ | Basso (警告) | 220 | 2 |

**设计理念**:
- **Stop**: 低打扰，完成即可，无需语音
- **Input**: 高优先级，需要用户立即响应
- **Error**: 最高优先级，强提示确保用户注意

### 🛡️ Hookify 安全防护

已配置的安全规则：

| 规则文件 | 事件 | 模式 | 动作 | 用途 |
|----------|------|------|------|------|
| `voice-safety-rm` | bash | `rm\s+(-rf\|-fr)` | block | 阻止危险删除 |
| `voice-safety-git` | bash | `git\s+push.*--force` | block | 阻止强制推送 |
| `voice-safety-env` | bash | `git\s+(add\|commit).*\.env` | warn | 警告敏感文件 |

### 🎤 智能语音

- **自动语言检测**: 根据内容选择中文/英文语音
- **中文**: Ting-Ting (女声)
- **英文**: Alex (男声)
- **语速控制**: Error 加速到 220 wpm，其他 180 wpm

---

## 架构设计

### 完整数据流

```
用户语音输入 (Typeless/Dictation)
    ↓
UserPromptSubmit Hook (Hookify)
    ↓
PreToolUse Hook (Hookify 安全检查)
    ↓
Claude Code 执行任务
    ↓
PostToolUse Hook (Bash 退出码检查)
    ↓
Stop / Notification / Error Hook
    ↓
notify.sh (通知脚本)
    ↓
桌面通知 + 语音提示
```

### Hook 事件触发顺序

```
1. UserPromptSubmit    ← 用户提交提示词时
2. PreToolUse          ← 工具执行前 (Hookify 安全检查)
3. [执行工具]
4. PostToolUse         ← 工具执行后 (检查 Bash 退出码)
5. Stop / Error        ← 任务结束/出错时
```

---

## 安装部署

### 前置要求

- macOS 10.10 或更高版本
- Homebrew 包管理器
- Claude Code 已安装

### 步骤 1: 安装通知工具

```bash
# 安装 terminal-notifier (推荐)
brew install terminal-notifier

# 验证安装
terminal-notifier -message "测试" -title "测试"
```

### 步骤 2: 创建通知脚本

已提供完整的 `notify.sh` 脚本，支持三级通知：

```bash
# 脚本位置
~/.claude/scripts/notify.sh

# 确认执行权限
chmod +x ~/.claude/scripts/notify.sh

# 测试脚本
~/.claude/scripts/notify.sh "测试" "测试消息" "测试语音" "stop"
```

### 步骤 3: 配置原生 Hooks

编辑 `~/.claude/settings.json`，添加以下配置：

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

### 步骤 4: 创建 Hookify 安全规则

三个安全规则文件已创建在 `~/.claude/` 目录：

1. `hookify.voice-safety-rm.local.md` - 阻止危险删除
2. `hookify.voice-safety-git.local.md` - 阻止强制 Git 操作
3. `hookify.voice-safety-env.local.md` - 警告敏感文件操作

**注意**: Hookify 规则即时生效，无需重启。

### 步骤 5: 重启 Claude Code

```bash
# 退出当前会话
exit

# 重新启动
claude
```

---

## 配置详解

### notify.sh 参数说明

```bash
notify.sh "标题" "消息" "语音内容" "级别"
```

| 参数 | 必需 | 说明 | 示例 |
|------|------|------|------|
| 标题 | 是 | 通知标题 | `"✅ 任务完成"` |
| 消息 | 是 | 通知正文 | `"Claude Code 任务已成功完成"` |
| 语音内容 | 否 | 语音播报内容 | `"任务完成"` (空字符串=无语音) |
| 级别 | 否 | 通知级别 | `stop`/`input`/`error`/`default` |

### settings.json Hook 配置

#### Stop Hook

```json
{
  "matcher": "",  // 空 matcher 匹配所有 Stop 事件
  "hooks": [{
    "type": "command",
    "command": "...",
    "timeout": 10  // 超时时间(秒)
  }]
}
```

#### Notification Hook

```json
{
  "matcher": "permission_prompt|idle_prompt",  // 正则过滤
  "hooks": [...]
}
```

**常用 matcher**:
- `permission_prompt`: 权限请求
- `idle_prompt`: 空闲等待
- `user_input_required`: 需要用户输入

#### PostToolUse Hook

检查 Bash 命令退出码：

```bash
if [ -n "$CLAUDE_TOOL_EXIT_CODE" ] && [ "$CLAUDE_TOOL_EXIT_CODE" != "0" ]; then
  # 命令失败，触发通知
fi
```

**环境变量**:
- `$CLAUDE_TOOL_EXIT_CODE`: Bash 命令退出码
- `$CLAUDE_TOOL_NAME`: 工具名称

### Hookify 规则格式

```yaml
---
name: rule-identifier        # 规则唯一标识
enabled: true|false          # 是否启用
event: bash|file|stop|prompt # 事件类型
pattern: regex-pattern       # 正则匹配模式
action: block|warn           # 动作类型
---

显示给 Claude 的消息内容 (支持 Markdown)
```

---

## 使用指南

### 语音输入设置

#### 方式 A: Typeless (推荐)

1. 下载安装 [Typeless](https://www.typeless.com/)
2. 配置全局快捷键 (如 `Option + Space`)
3. 在终端中按快捷键激活
4. 说出指令: "claude create a python hello world script"

#### 方式 B: macOS 内置听写

1. 系统设置 → 键盘 → 听写
2. 启用听写，设置快捷键 (如双击 `Fn`)
3. 在终端中按快捷键激活
4. 说出指令后再次按快捷键结束

### 典型工作流

```
1. 语音输入指令
   ↓
2. Claude Code 开始执行
   ↓
3. [可选] 收到 Input 通知 - 需要权限/输入
   ↓
4. 任务完成 - 收到 Stop 通知 (仅桌面)
   或
   任务失败 - 收到 Error 通知 (重复语音)
```

### 示例场景

#### 场景 1: 长时间测试

```
语音: "claude run pytest"
→ 离开座位喝咖啡 ☕
→ 10 分钟后收到通知
  - 成功: Stop 通知 (轻柔提示音)
  - 失败: Error 通知 (重复语音)
```

#### 场景 2: 需要权限

```
语音: "claude write a script to modify system files"
→ Claude 需要 Write 权限
→ 收到 Input 通知: "需要输入，请回到终端"
→ 回到终端确认权限
```

#### 场景 3: 危险操作被拦截

```
语音: "claude delete all temporary files with rm rf"
→ Hookify 拦截 `rm -rf` 命令
→ Claude 收到提示并询问您
```

---

## 故障排查

### 问题 1: 通知未显示

**诊断**:
```bash
# 检查脚本权限
ls -la ~/.claude/scripts/notify.sh

# 手动测试
~/.claude/scripts/notify.sh "测试" "测试消息" "测试" "stop"

# 检查日志
cat ~/.claude/scripts/notify.log
```

**解决**:
- 添加执行权限: `chmod +x ~/.claude/scripts/notify.sh`
- 安装 terminal-notifier: `brew install terminal-notifier`
- 检查系统通知权限: 系统设置 → 通知 → Terminal

### 问题 2: 通知被替换或出现 Removing previously sent notification

**诊断**:
```bash
# 检查 notify.sh 是否使用 -group
grep -n -- "-group" ~/.claude/scripts/notify.sh
```

**解决**:
- 移除 terminal-notifier 的 `-group` 参数
- 过滤提示信息: `2>&1 | grep -v "Removing previously sent notification"`

### 问题 3: 语音不播放

**诊断**:
```bash
# 测试 say 命令
say "测试"

# 检查音量
osascript -e "output volume of (get volume settings)"
```

**解决**:
- 确认音量未静音
- 确认使用 `input` 或 `error` 级别 (Stop 无语音)

### 问题 4: Hookify 规则不生效

**诊断**:
```bash
# 查看规则
/hookify:list

# 检查文件
cat ~/.claude/hookify.voice-safety-rm.local.md
```

**解决**:
- 确认文件名: `hookify.*.local.md`
- 确认 `enabled: true`
- 使用 `/hookify:configure` 管理规则

### 问题 5: Hooks 未生效

**诊断**:
```bash
# 验证 JSON 格式
jq . ~/.claude/settings.json

# 检查日志
tail -f ~/.claude/scripts/notify.log
```

**解决**:
- 修复 JSON 格式错误
- **重启 Claude Code** (settings.json 需要重启)

---

## 进阶定制

### 自定义语音模型

查看可用语音:
```bash
say -v ?
```

**常用中文语音**:
- `Ting-Ting` - 普通话女声
- `Sin-Ji` - 普通话男声

**常用英文语音**:
- `Alex` - 美式英语男声
- `Samantha` - 美式英语女声

### 自定义提示音

可用系统提示音:
- `Basso` - 低沉警告 ⚠️
- `Ping` - 清脆提示 📳
- `Pop` - 轻柔弹出 💭
- `Glass` - 玻璃敲击 🔔

### 添加自定义 Hookify 规则

#### 示例: 防止生产环境误操作

`~/.claude/hookify.production-safety.local.md`:
```markdown
---
name: production-safety
enabled: true
event: bash
pattern: kubectl.*--context.*prod|aws.*--profile.*prod
action: block
---

🚫 **生产环境操作已阻止**

检测到尝试在生产环境执行命令。请手动确认后执行。
```

### 集成到其他工具

```bash
# npm 构建
npm run build && \
  ~/.claude/scripts/notify.sh "构建完成" "项目构建成功" "构建完成" "stop"

# pytest 测试
pytest && \
  ~/.claude/scripts/notify.sh "测试通过" "所有测试通过" "" "stop" || \
  ~/.claude/scripts/notify.sh "测试失败" "部分测试失败" "测试失败" "error"
```

---

## 文件清单

```
~/.claude/
├── settings.json                            # 原生 Hooks 配置
├── scripts/
│   ├── notify.sh                            # 通知脚本
│   └── notify.log                           # 通知日志
└── hookify.*.local.md                       # Hookify 安全规则
    ├── hookify.voice-safety-rm.local.md
    ├── hookify.voice-safety-git.local.md
    └── hookify.voice-safety-env.local.md
```

---

## 许可证

MIT License

---

## 致谢

- [Claude Code](https://code.claude.com)
- [Hookify Plugin](https://github.com/anthropics/hookify)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier)
- [Typeless](https://www.typeless.com)
