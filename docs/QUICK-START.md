# 快速开始指南

> 5 分钟快速部署 Claude Code 语音工作流

---

## ⚡ 一分钟了解

本项目为 Claude Code 添加**智能通知系统** + **语音安全防护**：

```
语音输入 → 安全检查 → 执行任务 → 自动通知
```

**核心功能**:
- ✅ 任务完成时自动通知（桌面 + 语音）
- ✅ 需要输入时语音提醒
- ✅ 命令失败时强提示（重复语音）
- ✅ 阻止危险命令（`rm -rf`, `git push -f`）

---

## 📦 快速安装（3步）

### 1. 安装通知工具（1分钟）

```bash
brew install terminal-notifier
```

### 2. 验证脚本（1分钟）

检查通知脚本是否存在：

```bash
ls -la ~/.claude/scripts/notify.sh
```

如果不存在，脚本已在本项目中提供，无需手动创建。

### 3. 重启 Claude Code（1分钟）

```bash
exit
claude
```

✅ 完成！现在可以开始使用了。

---

## 🎯 快速测试

### 测试 1: 通知脚本

```bash
# Stop 级别（无语音）
~/.claude/scripts/notify.sh '✅ 测试' '任务完成' '' 'stop'

# Input 级别（有语音）
~/.claude/scripts/notify.sh '🔔 测试' '需要输入' '请回来' 'input'

# Error 级别（重复语音）
~/.claude/scripts/notify.sh '❌ 测试' '任务失败' '出错了' 'error'
```

**期望结果**:
- Stop: 只有桌面通知 + Pop 音
- Input: 桌面通知 + Ping 音 + 语音 1 次
- Error: 桌面通知 + Basso 音 + 语音 2 次

### 测试 2: 自动化测试套件（推荐）

运行完整的自动化测试：

```bash
./run_tests.sh
```

**测试内容**:
- ✅ 系统环境检查（4项）
- ✅ 配置文件验证（5项）
- ✅ Hookify 规则检查（3项）
- ✅ 通知功能测试（5项）
- ✅ 日志和语音验证

**期望结果**: 显示 `所有必需测试已通过！🎉`

### 测试 3: 安全规则

在 Claude Code 中尝试：

```
请运行 rm -rf /tmp/test
```

**期望结果**: Hookify 拦截并提示"阻止危险的删除命令"

---

## 📚 配置说明

### 通知级别

| 级别 | 桌面 | 语音 | 用途 |
|------|------|------|------|
| `stop` | ✅ | ❌ | 任务完成 |
| `input` | ✅ | ✅ | 需要输入 |
| `error` | ✅ | ✅✅ | 命令失败 |

### 已配置的 Hooks

- **Stop**: 任务完成 → Stop 通知
- **Notification**: 需要输入 → Input 通知
- **PostToolUse**: Bash 失败 → Error 通知
- **Error**: 系统错误 → Error 通知

### Hookify 安全规则

- `rm -rf` → 阻止
- `git push -f` → 阻止
- `git add .env` → 警告

---

## 🎤 语音输入设置

### 方式 A: macOS 内置听写（免费）

1. 系统设置 → 键盘 → 听写
2. 启用听写，快捷键设为双击 `Fn`
3. 在终端按 `Fn Fn` 激活
4. 说出指令后再按 `Fn Fn` 结束

### 方式 B: Typeless（推荐）

1. 下载 [Typeless](https://www.typeless.com/)
2. 设置全局快捷键
3. 在终端按快捷键即可输入

---

## 🔧 故障排查

### 问题：通知未显示

**最常见原因：系统通知权限未开启** ⚠️

1. 打开 **系统设置** → **通知**
2. 搜索并找到 **Terminal** 或 **terminal-notifier**
3. 确保以下选项已启用：
   - ✅ 允许通知
   - ✅ 横幅样式：选择 **横幅**（不是"无"）
   - ✅ 在通知中心显示
   - ✅ 播放声音

4. 测试通知：
```bash
# 手动测试（应该看到横幅）
~/.claude/scripts/notify.sh "🔔 测试" "您能看到这个通知吗？" "测试" "input"

# 检查脚本存在
ls -la ~/.claude/scripts/notify.sh

# 查看通知历史
terminal-notifier -list ALL
```

5. 如果仍然不显示：
   - 检查是否开启了"勿扰模式"或"专注模式"
   - 重启 Terminal 应用

### 问题：语音不播放

```bash
# 测试 say 命令
say "测试"

# 注意：Stop 级别默认无语音！
# 使用 input 或 error 级别测试
```

### 问题：Hookify 不生效

```bash
# 查看规则
/hookify:list

# 检查规则文件
ls -la ~/.claude/hookify.*.local.md
```

### 问题：Hooks 未生效

```bash
# 验证 JSON
jq . ~/.claude/settings.json

# 重启 Claude Code
exit && claude
```

---

## 📖 完整文档

- **[实施指南](./README-实施指南.md)** - 详细配置说明
- **[测试用例](./TEST-CASES.md)** - 17个测试场景
- **[原始设计文档](../语音驱动的AI编码工作流：设计与实施完整指南.md)** - 架构设计

---

## 🎓 使用示例

### 场景 1: 长时间任务

```bash
# 语音输入
"claude run pytest"

# → 离开座位
# → 10分钟后自动通知
```

### 场景 2: 需要权限

```bash
# 语音输入
"claude create a new file"

# → 收到 Input 通知: "需要输入"
# → 回到终端确认权限
```

### 场景 3: 命令失败

```bash
# 语音输入
"claude run a failing command"

# → 收到 Error 通知（重复2次）
# → 检查错误并修复
```

---

## ⚙️ 自定义配置

### 修改语音

编辑 `~/.claude/scripts/notify.sh`:

```bash
# 中文固定用 Ting-Ting
voice="Ting-Ting"

# 英文固定用 Samantha
voice="Samantha"
```

### 修改提示音

编辑 `~/.claude/scripts/notify.sh`:

```bash
case "$LEVEL" in
    error)
        SOUND_NAME="Funk"  # 改用 Funk 音效
        ;;
esac
```

### 添加自定义规则

创建 `~/.claude/hookify.my-rule.local.md`:

```markdown
---
name: my-rule
enabled: true
event: bash
pattern: your-pattern-here
action: block
---

您的提示消息
```

---

## 📝 检查清单

安装完成后，确认以下项目：

- [ ] `brew list | grep terminal-notifier` 有输出
- [ ] `~/.claude/scripts/notify.sh` 文件存在且可执行
- [ ] `~/.claude/settings.json` 包含 hooks 配置
- [ ] `~/.claude/hookify.*.local.md` 三个规则文件存在
- [ ] 手动测试三种通知级别都正常
- [ ] `/hookify:list` 显示三个规则
- [ ] 重启过 Claude Code

全部勾选 = 安装成功！🎉

---

## 🆘 需要帮助？

1. 查看详细文档: [实施指南](./README-实施指南.md)
2. 运行测试套件: [测试用例](./TEST-CASES.md)
3. 查看日志: `cat ~/.claude/scripts/notify.log`

---

**快速开始指南版本**: v2.0  
**最后更新**: 2026-01-19
