# AGENTS.md

## 适用范围
本文件适用于整个仓库。

## 项目概览
- 目标：为 Claude Code 提供语音驱动工作流、通知与安全钩子。
- 主要产物为 Markdown 文档与 Bash 测试脚本。
- 运行时资产（notify.sh、Hookify 规则、settings.json）位于 `~/.claude`。

## 构建、检查与测试
- 构建：仓库内无构建系统。
- Lint：未配置 lint 工具。
- 自动化测试：运行 `./run_tests.sh`。
- 手动测试：参考 `docs/TEST-CASES.md` 中的场景。

### 单个测试的运行方式
- `run_tests.sh` 必定执行完整套件，不支持选择单项。
- 需要执行单测时，直接运行 `docs/TEST-CASES.md` 中对应命令。
- 示例：`~/.claude/scripts/notify.sh '✅ 测试完成' '...' '' 'stop'`。

### 可选系统检查
- `terminal-notifier -message "测试" -title "测试"`：验证通知工具。
- `say "测试"`：验证语音合成可用。
- `jq . ~/.claude/settings.json`：验证配置 JSON（如果安装了 jq）。

## 依赖与环境
- 目标平台为 macOS 10.10+。
- `terminal-notifier` 通过 Homebrew 安装。
- Hookify 规则位于 `~/.claude/hookify.*.local.md`。

## 代码风格规范

### Bash 脚本
- 使用 `#!/bin/bash`，尽量保持 POSIX 兼容。
- 使用 `set -e` 早退出；仅在安全时添加 `set -u`。
- 使用显式函数（如 `test_case`、`manual_test`）并配合 `local` 变量。
- 函数体和代码块缩进 4 空格。
- 变量引用必须加引号：`"$var"`。
- `eval` 仅在不可避免时使用，并优先直接调用命令。
- 只有在调用方预期时才将输出重定向到 `/dev/null`。
- 面向用户的输出保持简洁、以状态为核心。
- 失败需清晰标注并返回明确的退出码。

### Markdown 文档
- 结构遵循 `README.md`、`docs/QUICK-START.md`、`docs/README-实施指南.md`。
- 标题保持中文风格以匹配现有文档。
- 命令示例使用 `bash` 代码块。
- 优先短段落与表格，避免长篇堆叠。
- 用户可见行为变化需同步更新版本/日期头部。

### JSON 与配置示例
- 使用 2 空格缩进。
- 示例保持精简，并与 `.claude/settings.json` 结构一致。
- 键和值均使用双引号。

### 命名约定
- 文档文件使用 kebab-case。
- 新增脚本使用 snake_case。
- Bash 函数使用 lower_snake_case。
- 常量使用全大写，局部变量使用 lower_snake_case。
- 变量名清晰可读，避免单字母命名。

### 错误处理
- 配置或依赖检查采用 fail-fast。
- 可选检查失败应记录为跳过，不应阻断流程。
- 拦截危险操作时需输出简短、明确的原因。

### 日志
- 遵循 `notify.sh` 的日志格式：`[level] title: message`。
- 只记录高价值事件，避免噪声。

### 安全与防护
- 禁止弱化 Hookify 规则或绕过安全检查。
- 默认不添加会删除或覆盖用户文件的命令。
- 文档中避免出现密钥或示例凭据。

### 本地化
- 若现有文本非中英双语，则保持中文输出。
- 示例默认中文表达，风格与现有文档一致。

## 文档更新要求
- 行为或依赖变化需更新 `README.md`。
- 测试覆盖变化需更新 `docs/TEST-CASES.md`。
- 配置说明变更需更新 `docs/README-实施指南.md`。

## 仓库约定
- 根目录脚本直接执行（如 `./run_tests.sh`）。
- 运行时资产放在用户目录 `~/.claude`，不写入仓库。
- 未经确认不要新增运行时文件。

## Cursor 与 Copilot 规则
- 未发现 `.cursor/rules`、`.cursorrules` 或 `.github/copilot-instructions.md`。

## 推荐变更流程
1. 修改文档或脚本。
2. 若行为受影响，执行 `./run_tests.sh`。
3. 通知相关变更需确认 `docs/TEST-CASES.md` 的手动步骤。
4. 检查用户可见文本与当前语气一致。

## 给代理的提示
- 仓库以文档为主，修改尽量小且聚焦。
- 所有命令需适配 macOS 终端。
- 未明确请求时避免添加表情符号。
- 自动化测试结果以 `run_tests.sh` 输出为准。
- 测试会触发通知与语音，远程运行需提前提醒。

## 常用参考命令
- 安装通知工具：`brew install terminal-notifier`。
- 快速通知验证：`~/.claude/scripts/notify.sh '测试' '消息' '语音' 'input'`。
- 查看 Hookify 规则：`/hookify:list`（Claude Code 内）。
- 查看日志：`cat ~/.claude/scripts/notify.log`。

## 故障排查提示
- 无通知：确认 macOS 通知权限。
- 无语音：确认 `say` 可用与系统音量。
- 规则未触发：检查 `~/.claude` 下规则文件位置。

## PR 前检查清单
- 文档中的命令可直接复制执行。
- 新脚本为 `bash` 并具可执行权限。
- 表格对齐且在 Markdown 中可读。
- 行为变化时更新日期与版本信息。

## 文件职责
- `run_tests.sh`：自动化测试入口。
- `README.md`：项目概览与快速使用。
- `docs/QUICK-START.md`：快速上手流程。
- `docs/README-实施指南.md`：完整配置与架构说明。
- `docs/TEST-CASES.md`：手动测试用例集合。

## 需要澄清的场景
- 修改 `notify.sh` 时需确认是否编辑 `~/.claude` 下脚本。
- 新增 Hookify 规则需确认安装目录。
- 调整通知级别需确认语音与提示音行为。

## 行长度建议
- Markdown 行长尽量控制在 100 字符内。
- 过长命令必要时使用 `\` 换行。

## 其他约束
- 仅支持 macOS，避免引入 Linux-only 命令。
- shell 示例需兼容系统默认 Bash。
- 通知优先使用 `terminal-notifier`。
- 非必要不添加新依赖。

## 维护建议
- 系统升级或通知工具更新后重新跑手动测试。
- 重大变更需在 `README.md` 版本历史中记录。

## End
