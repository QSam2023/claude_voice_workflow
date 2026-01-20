# Claude Code 语音工作流 - 测试用例

**版本**: 2.0  
**测试日期**: 2026-01-19  
**测试环境**: macOS

---

## 📋 测试概览

| 测试类别 | 用例数 | 状态 |
|----------|--------|------|
| 基础功能测试 | 6 | ⏳ 待测试 |
| Hookify 安全测试 | 3 | ⏳ 待测试 |
| 集成测试 | 4 | ⏳ 待测试 |
| 边界测试 | 4 | ⏳ 待测试 |
| **总计** | **17** | **0/17** |

---

## 第一部分：基础功能测试

### T1.1 通知脚本 - Stop 级别（无语音）

**测试目的**: 验证 Stop 级别通知仅显示桌面通知，不播放语音

**前置条件**:
- `notify.sh` 脚本已安装且有执行权限
- 系统音量未静音

**测试步骤**:
```bash
~/.claude/scripts/notify.sh '✅ 测试完成' '这是 Stop 级别测试' '' 'stop'
```

**期望结果**:
- ✅ 桌面右上角显示通知
- ✅ 播放 "Pop" 轻柔提示音
- ❌ **不播放**语音提示
- ✅ 日志记录: `[stop] ✅ 测试完成: 这是 Stop 级别测试`

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T1.2 通知脚本 - Input 级别（有语音）

**测试目的**: 验证 Input 级别通知显示桌面通知并播放语音

**前置条件**:
- `notify.sh` 脚本已安装
- 系统音量未静音

**测试步骤**:
```bash
~/.claude/scripts/notify.sh '🔔 需要输入' '请回到终端' '需要输入' 'input'
```

**期望结果**:
- ✅ 桌面通知显示
- ✅ 播放 "Ping" 清脆提示音
- ✅ 播放语音: "需要输入" (正常语速 180 wpm)
- ✅ 语音播放**1次**
- ✅ 日志记录: `[input] 🔔 需要输入: 请回到终端`

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T1.3 通知脚本 - Error 级别（重复语音）

**测试目的**: 验证 Error 级别通知播放加速语音并重复

**前置条件**:
- `notify.sh` 脚本已安装
- 系统音量未静音

**测试步骤**:
```bash
~/.claude/scripts/notify.sh '❌ 任务失败' '命令执行失败' '任务失败' 'error'
```

**期望结果**:
- ✅ 桌面通知显示
- ✅ 播放 "Basso" 低沉警告音
- ✅ 播放语音: "任务失败" (加速语速 220 wpm)
- ✅ 语音播放**2次**，中间间隔 0.5 秒
- ✅ 日志记录: `[error] ❌ 任务失败: 命令执行失败`

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T1.4 中文语音识别

**测试目的**: 验证脚本自动识别中文并使用 Ting-Ting 语音

**前置条件**:
- macOS 已安装 Ting-Ting 中文语音包

**测试步骤**:
```bash
~/.claude/scripts/notify.sh '测试' '中文语音测试' '任务已完成' 'input'
```

**期望结果**:
- ✅ 使用 Ting-Ting 女声播放
- ✅ 语音清晰，发音准确

**验证方法**:
```bash
# 对比测试
say -v "Ting-Ting" "任务已完成"
```

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T1.5 英文语音识别

**测试目的**: 验证脚本自动识别英文并使用 Alex 语音

**前置条件**:
- macOS 已安装 Alex 英文语音包（默认）

**测试步骤**:
```bash
~/.claude/scripts/notify.sh 'Test' 'English voice test' 'Task completed' 'input'
```

**期望结果**:
- ✅ 使用 Alex 男声播放
- ✅ 语音清晰，发音准确

**验证方法**:
```bash
# 对比测试
say -v "Alex" "Task completed"
```

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T1.6 日志记录功能

**测试目的**: 验证通知脚本正确记录日志

**前置条件**:
- `notify.sh` 脚本已安装

**测试步骤**:
```bash
# 清空日志
> ~/.claude/scripts/notify.log

# 触发三种级别通知
~/.claude/scripts/notify.sh 'Stop测试' '消息1' '' 'stop'
~/.claude/scripts/notify.sh 'Input测试' '消息2' '测试' 'input'
~/.claude/scripts/notify.sh 'Error测试' '消息3' '错误' 'error'

# 查看日志
cat ~/.claude/scripts/notify.log
```

**期望结果**:
```
[2026-01-19 XX:XX:XX] [stop] Stop测试: 消息1
[2026-01-19 XX:XX:XX] [input] Input测试: 消息2
[2026-01-19 XX:XX:XX] [error] Error测试: 消息3
```

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

## 第二部分：Hookify 安全测试

### T2.1 阻止危险删除命令

**测试目的**: 验证 Hookify 拦截 `rm -rf` 命令

**前置条件**:
- Hookify 插件已启用
- `PreToolUse` 钩子已写入 `~/.claude/settings.json`
- `.claude/hookify.voice-safety-rm.local.md` 已指向规则文件
- `hookify.voice-safety-rm.local.md` 规则已创建且启用

**测试步骤**:
在 Claude Code 中执行:
```
让我帮你删除临时文件，运行 rm -rf /tmp/test
```

**期望结果**:
- ✅ Hookify 拦截命令
- ✅ Claude 收到提示: "语音安全：阻止危险的删除命令"
- ✅ Claude 询问用户是否确认
- ❌ 命令**不会**自动执行

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T2.2 阻止强制 Git 推送

**测试目的**: 验证 Hookify 拦截 `git push -f` 命令

**前置条件**:
- Hookify 插件已启用
- `PreToolUse` 钩子已写入 `~/.claude/settings.json`
- `.claude/hookify.voice-safety-git.local.md` 已指向规则文件
- `hookify.voice-safety-git.local.md` 规则已创建且启用

**测试步骤**:
在 Claude Code 中执行:
```
强制推送到远程仓库，运行 git push origin main --force
```

**期望结果**:
- ✅ Hookify 拦截命令
- ✅ Claude 收到提示: "语音安全：阻止强制 Git 操作"
- ✅ Claude 询问用户是否确认
- ❌ 命令**不会**自动执行

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T2.3 警告 .env 文件操作

**测试目的**: 验证 Hookify 警告 `.env` 文件 Git 操作

**前置条件**:
- Hookify 插件已启用
- `PreToolUse` 钩子已写入 `~/.claude/settings.json`
- `.claude/hookify.voice-safety-env.local.md` 已指向规则文件
- `hookify.voice-safety-env.local.md` 规则已创建且启用

**测试步骤**:
在 Claude Code 中执行:
```
添加环境变量文件到 git，运行 git add .env
```

**期望结果**:
- ✅ Hookify 发出警告（不阻止）
- ✅ Claude 收到提示: "语音安全：检测到敏感文件操作"
- ⚠️ Claude 提醒用户但可以继续执行

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

## 第三部分：集成测试

### T3.1 完整工作流 - 任务成功

**测试目的**: 验证从语音输入到任务完成的完整流程

**前置条件**:
- 所有组件已安装并配置
- Claude Code 已重启

**测试步骤**:
1. 使用语音输入（或手动）: "claude create a file named test.txt with hello world"
2. 等待任务执行完成

**期望结果**:
- ✅ Hookify 不拦截（安全命令）
- ✅ Claude 创建文件
- ✅ 任务完成后收到 Stop 通知
- ✅ 通知仅桌面显示，无语音
- ✅ 文件 `test.txt` 被创建且内容正确

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T3.2 PostToolUse Hook - Bash 失败

**测试目的**: 验证 Bash 命令失败时触发 Error 通知

**前置条件**:
- `settings.json` 中 PostToolUse Hook 已配置
- Claude Code 已重启

**测试步骤**:
在 Claude Code 中执行:
```
运行一个会失败的命令: bash -c "exit 1"
```

**期望结果**:
- ✅ Bash 命令执行并返回退出码 1
- ✅ PostToolUse Hook 检测到失败
- ✅ 触发 Error 通知
- ✅ 桌面通知显示: "❌ Bash 命令失败"
- ✅ 语音播放: "Bash 命令执行失败" (重复2次)

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T3.3 Notification Hook - 权限请求

**测试目的**: 验证需要权限时触发 Input 通知

**前置条件**:
- `settings.json` 中 Notification Hook 已配置
- Claude Code 已重启
- 权限模式设置为需要确认

**测试步骤**:
在 Claude Code 中执行需要权限的操作:
```
请创建一个新文件 sensitive.txt
```

**期望结果**:
- ✅ Claude 请求 Write 权限
- ✅ 触发 Notification Hook
- ✅ 收到 Input 通知: "🔔 需要您的输入"
- ✅ 语音播放: "需要输入，请回到终端"
- ✅ 用户确认后继续执行

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T3.4 Error Hook - 系统错误

**测试目的**: 验证 Claude 内部错误时触发 Error 通知

**前置条件**:
- `settings.json` 中 Error Hook 已配置
- Claude Code 已重启

**测试步骤**:
触发一个系统级错误（例如工具调用失败）

**期望结果**:
- ✅ Error Hook 被触发
- ✅ 收到 Error 通知: "❌ 系统错误"
- ✅ 语音播放: "系统错误" (重复2次)

**注意**: 此测试较难主动触发，可能需要特殊场景

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

## 第四部分：边界测试

### T4.1 terminal-notifier 未安装（降级测试）

**测试目的**: 验证 terminal-notifier 未安装时自动降级到 osascript

**前置条件**:
- 临时卸载或重命名 terminal-notifier

**测试步骤**:
```bash
# 备份 terminal-notifier
sudo mv /usr/local/bin/terminal-notifier /usr/local/bin/terminal-notifier.bak

# 触发通知
~/.claude/scripts/notify.sh '降级测试' '使用 osascript' '测试' 'input'

# 恢复
sudo mv /usr/local/bin/terminal-notifier.bak /usr/local/bin/terminal-notifier
```

**期望结果**:
- ✅ 桌面通知仍然显示（通过 osascript）
- ✅ 语音正常播放
- ✅ 日志正常记录

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T4.2 空语音消息参数

**测试目的**: 验证空语音消息时不播放语音

**前置条件**:
- `notify.sh` 脚本已安装

**测试步骤**:
```bash
# 空字符串
~/.claude/scripts/notify.sh '测试' '空语音测试' '' 'input'

# 未提供参数
~/.claude/scripts/notify.sh '测试' '未提供语音' 'input'
```

**期望结果**:
- ✅ 桌面通知显示
- ✅ 提示音播放
- ❌ **不播放**语音（因为语音内容为空）

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T4.3 并发通知测试

**测试目的**: 验证短时间内多个通知不会冲突

**前置条件**:
- `notify.sh` 脚本已安装

**测试步骤**:
```bash
# 快速连续触发3个不同级别的通知
~/.claude/scripts/notify.sh 'Stop' '通知1' '' 'stop' &
~/.claude/scripts/notify.sh 'Input' '通知2' '输入' 'input' &
~/.claude/scripts/notify.sh 'Error' '通知3' '错误' 'error' &
wait
```

**期望结果**:
- ✅ 3个桌面通知都正常显示
- ✅ 终端无 "Removing previously sent notification" 提示
- ✅ 语音按顺序播放（Input 1次 + Error 2次）
- ✅ 日志记录3条

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

### T4.4 特殊字符处理

**测试目的**: 验证通知内容包含特殊字符时正常工作

**前置条件**:
- `notify.sh` 脚本已安装

**测试步骤**:
```bash
~/.claude/scripts/notify.sh '测试"引号"' "消息's单引号" '特殊$字符' 'input'
```

**期望结果**:
- ✅ 桌面通知正确显示所有字符
- ✅ 语音正常播放
- ✅ 日志正确记录

**实际结果**: _待填写_

**状态**: ⏳ 待测试

---

## 第五部分：手动验证清单

### 语音输入集成

- [ ] Typeless 可以在终端中激活
- [ ] macOS 听写可以在终端中工作
- [ ] 语音转文本准确率可接受
- [ ] 语音可以正确识别 Claude Code 命令

### 用户体验

- [ ] Stop 通知不会过于打扰（无语音）
- [ ] Input 通知能够及时吸引注意
- [ ] Error 通知足够明显（重复语音）
- [ ] 中文语音发音清晰自然
- [ ] 英文语音发音清晰自然

### 安全性

- [ ] Hookify 规则能够有效拦截危险命令
- [ ] 警告信息清晰明确
- [ ] 不会误拦截正常命令

### 性能

- [ ] 通知延迟在可接受范围内 (< 2 秒)
- [ ] 语音播放流畅，无卡顿
- [ ] 多个通知不会导致系统卡顿

---

## 测试报告模板

**测试执行者**: _姓名_  
**测试日期**: _日期_  
**环境信息**:
- macOS 版本: _版本号_
- Claude Code 版本: _版本号_
- terminal-notifier 版本: _版本号（如已安装）_

**测试结果汇总**:
- 通过: _X_ / 17
- 失败: _X_ / 17
- 跳过: _X_ / 17

**发现的问题**:
1. _问题描述_
2. _问题描述_

**建议改进**:
1. _改进建议_
2. _改进建议_

---

## 自动化测试脚本（可选）

创建 `run_tests.sh`:

```bash
#!/bin/bash
# 自动化测试脚本

echo "=== Claude Code 语音工作流测试套件 ==="
echo ""

# 测试计数器
PASSED=0
FAILED=0
TOTAL=0

# 测试函数
test_case() {
    local name="$1"
    local command="$2"
    
    TOTAL=$((TOTAL + 1))
    echo "[$TOTAL] 测试: $name"
    
    if eval "$command" > /dev/null 2>&1; then
        echo "    ✅ 通过"
        PASSED=$((PASSED + 1))
    else
        echo "    ❌ 失败"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# 基础功能测试
echo "--- 基础功能测试 ---"
test_case "Stop 级别通知" "~/.claude/scripts/notify.sh 'Test' 'Test' '' 'stop'"
test_case "Input 级别通知" "~/.claude/scripts/notify.sh 'Test' 'Test' 'Test' 'input'"
test_case "Error 级别通知" "~/.claude/scripts/notify.sh 'Test' 'Test' 'Test' 'error'"

# 日志测试
echo "--- 日志测试 ---"
test_case "日志文件存在" "test -f ~/.claude/scripts/notify.log"

# Hookify 测试
echo "--- Hookify 测试 ---"
test_case "rm 规则文件存在" "test -f ~/.claude/hookify.voice-safety-rm.local.md"
test_case "git 规则文件存在" "test -f ~/.claude/hookify.voice-safety-git.local.md"
test_case "env 规则文件存在" "test -f ~/.claude/hookify.voice-safety-env.local.md"

# 配置测试
echo "--- 配置测试 ---"
test_case "settings.json 格式正确" "jq . ~/.claude/settings.json"
test_case "notify.sh 可执行" "test -x ~/.claude/scripts/notify.sh"

# 总结
echo "================================"
echo "测试完成: $PASSED/$TOTAL 通过"
if [ $FAILED -gt 0 ]; then
    echo "失败: $FAILED"
fi
echo "================================"
```

使用方法:
```bash
chmod +x run_tests.sh
./run_tests.sh
```

---

**测试文档版本**: v2.3  
**最后更新**: 2026-01-20
