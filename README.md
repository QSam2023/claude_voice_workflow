# Claude Code 语音驱动 AI 编码工作流

> 基于 Claude Code + Hookify 的多模态通知系统

**版本**: 2.3
**更新日期**: 2026-01-20

---

## 🎯 项目简介

为 Claude Code 添加智能通知系统和语音安全防护，通过语音输入控制 AI 编码，任务完成时自动通知。

### 核心特性

- 🎤 **语音输入集成** - Typeless / macOS Dictation
- 🔔 **三级智能通知** - 桌面 + 语音多模态反馈
- 🛡️ **安全防护** - Hookify 规则拦截危险命令
- 🎵 **智能语音** - 自动识别中文/英文

---

## 📚 文档导航

| 文档 | 用途 | 适合人群 |
|------|------|----------|
| **[文档索引](./docs/index.md)** | 文档入口与结构说明 | 所有用户 |
| **[快速开始](./docs/QUICK-START.md)** | 5分钟快速部署 | 首次使用 |
| **[实施指南](./docs/README-实施指南.md)** | 完整配置说明 | 详细部署 |
| **[测试用例](./docs/TEST-CASES.md)** | 17个测试场景 | 验证功能 |
| **[AI 自动化配置](./docs/ai-setup.md)** | 供 AI 读取的配置步骤（含 JSON/YAML 附录） | 自动化配置 |
| **[原始设计](./语音驱动的AI编码工作流：设计与实施完整指南.md)** | 架构设计 | 深入理解 |

---

## ⚡ 快速开始

```bash
# 1. 安装通知工具
brew install terminal-notifier

# 2. 重启 Claude Code
exit && claude

# 3. 测试通知
~/.claude/scripts/notify.sh '测试' '通知测试' '测试' 'input'
```

**详细步骤**: 查看 [快速开始指南](./docs/QUICK-START.md)

---

## 🎯 通知级别

| 级别 | 触发条件 | 桌面 | 语音 | 提示音 |
|------|----------|------|------|--------|
| Stop | 任务完成 | ✅ | ❌ | Pop |
| Input | 需要输入 | ✅ | ✅ | Ping |
| Error | 命令失败 | ✅ | ✅✅ | Basso |

---

## 🛡️ 安全防护

已配置 Hookify 规则：

- ✅ 阻止 `rm -rf` 危险删除
- ✅ 阻止 `git push -f` 强制推送  
- ⚠️ 警告 `.env` 文件提交

**注意**: Hookify 默认从项目目录的 `.claude/` 读取规则，可在项目内建立符号链接指向 `~/.claude`。

---

## 📁 项目结构

```
~/.claude/
├── settings.json                         # Hooks 配置
├── scripts/
│   ├── notify.sh                         # 通知脚本
│   └── notify.log                        # 日志
└── hookify.*.local.md                    # 安全规则
    ├── hookify.voice-safety-rm.local.md
    ├── hookify.voice-safety-git.local.md
    └── hookify.voice-safety-env.local.md

./.claude/                                # 项目内规则链接（可选）
└── hookify.*.local.md -> ~/.claude/...
```

---

## 🔧 使用示例

### 场景 1: 长时间测试

```
语音: "claude run pytest"
→ 离开座位 ☕
→ 收到通知: "任务完成"
```

### 场景 2: 危险操作拦截

```
语音: "claude delete with rm rf"
→ Hookify 拦截
→ Claude 询问确认
```

---

## 📝 文件清单

### 文档文件

- `README.md` - 项目概览（本文件）
- `QUICK-START.md` - 快速开始指南
- `README-实施指南.md` - 完整实施指南
- `TEST-CASES.md` - 测试用例集合
- `语音驱动的AI编码工作流：设计与实施完整指南.md` - 原始设计文档

### 脚本文件

- `run_tests.sh` - 自动化测试套件（17项测试）
- `~/.claude/scripts/notify.sh` - 通知脚本

### 配置文件

- `~/.claude/settings.json` - Claude Code Hooks 配置
- `~/.claude/hookify.*.local.md` - Hookify 安全规则

---

## 🧪 运行测试

### 自动化测试（推荐）

```bash
# 运行完整测试套件（17项测试）
./run_tests.sh
```

测试套件包括：
- ✅ 系统环境检查
- ✅ 配置文件验证
- ✅ Hookify 安全规则
- ✅ 三级通知功能
- ✅ 中英文语音测试
- ✅ 日志记录验证

### 手动测试

```bash
# 测试通知脚本
~/.claude/scripts/notify.sh '✅ 测试' '消息' '' 'stop'
~/.claude/scripts/notify.sh '🔔 测试' '消息' '语音' 'input'
~/.claude/scripts/notify.sh '❌ 测试' '消息' '错误' 'error'

# 查看 Hookify 规则
/hookify:list

# 查看日志
cat ~/.claude/scripts/notify.log
```

**完整测试**: 查看 [测试用例文档](./docs/TEST-CASES.md)

---

## 🎓 学习路径

### 新手用户

1. 阅读 [快速开始](./docs/QUICK-START.md)
2. 完成基础测试
3. 尝试语音输入

### 进阶用户

1. 阅读 [实施指南](./docs/README-实施指南.md)
2. 自定义通知配置
3. 添加 Hookify 规则

### 深入研究

1. 阅读 [原始设计文档](./语音驱动的AI编码工作流：设计与实施完整指南.md)
2. 理解架构设计
3. 扩展到其他工具

---

## 🔧 故障排查

| 问题 | 解决方案 |
|------|----------|
| 通知未显示 | **重要**: 检查系统设置 → 通知 → Terminal → 开启所有权限 |
| 通知有声音但无横幅 | 确保横幅样式设为"横幅"，不是"无" |
| 提示 Removing previously sent notification | 移除 `notify.sh` 中的 `-group` 并过滤该提示 |
| 语音不播放 | 测试 `say` 命令 / 确认级别非 stop |
| Hookify 不生效 | 运行 `/hookify:list` / 检查规则文件 |
| Hooks 未生效 | 验证 JSON 格式 / 重启 Claude Code |
| 测试失败 | 运行 `./run_tests.sh` 查看具体失败项 |

**详细排查**: 查看 [实施指南 - 故障排查](./docs/README-实施指南.md#故障排查)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献方式

1. Fork 本仓库
2. 创建功能分支: `git checkout -b feature/new-rule`
3. 提交更改: `git commit -m "feat: add xxx"`
4. 推送分支: `git push origin feature/new-rule`
5. 创建 Pull Request

---

## 📄 许可证

MIT License

---

## 🙏 致谢

- [Claude Code](https://code.claude.com) - AI 编码助手
- [Hookify Plugin](https://github.com/anthropics/hookify) - 规则引擎
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) - macOS 通知工具
- [Typeless](https://www.typeless.com) - 智能语音输入

---

## 📊 版本历史

### v2.3 (2026-01-20)
- 🛡️ 补充 Hookify 规则的项目路径说明
- 📝 更新 PreToolUse 配置与规则链接指引

### v2.2 (2026-01-20)
- 🧪 测试脚本提示 notify.sh 的 `-group` 风险
- 📝 增加通知被替换的排查说明
- 📚 更新实施指南与快速开始

### v2.1 (2026-01-19)
- 🐛 修复通知脚本 group 参数导致的通知替换问题
- 📝 添加自动化测试套件 `run_tests.sh`（17项测试）
- 📝 增强故障排查文档（重点：系统通知权限）
- ✨ 过滤 terminal-notifier 警告消息
- 📚 更新快速开始指南

### v2.0 (2026-01-19)
- ✨ 三级通知系统（Stop/Input/Error）
- ✨ Hookify 安全防护集成
- ✨ PostToolUse Hook 退出码检查
- 📝 完整文档体系
- 🧪 17 个测试用例

### v1.0 (2026-01-18)
- 🎉 初始版本
- ✨ 基础通知功能
- 📝 原始设计文档

---

**快速链接**:
- 📖 [快速开始](./docs/QUICK-START.md)
- 📚 [实施指南](./docs/README-实施指南.md)
- 🧪 [测试用例](./docs/TEST-CASES.md)
