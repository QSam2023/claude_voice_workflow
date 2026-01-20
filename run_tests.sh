#!/bin/bash
# Claude Code 语音工作流 - 自动化测试脚本
# 版本: 2.2
# 日期: 2026-01-20

set -e

echo "==================================================================="
echo "         Claude Code 语音工作流 - 测试套件 v2.2"
echo "==================================================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试计数器
PASSED=0
FAILED=0
SKIPPED=0
TOTAL=0

# 测试结果数组
declare -a FAILED_TESTS

# 测试函数
test_case() {
    local name="$1"
    local command="$2"
    local required="${3:-false}"

    TOTAL=$((TOTAL + 1))
    echo -ne "${BLUE}[$TOTAL]${NC} 测试: $name ... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 通过${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        if [ "$required" = "true" ]; then
            echo -e "${RED}❌ 失败（必需）${NC}"
            FAILED=$((FAILED + 1))
            FAILED_TESTS+=("$name")
        else
            echo -e "${YELLOW}⚠️  跳过（可选）${NC}"
            SKIPPED=$((SKIPPED + 1))
        fi
        return 1
    fi
}

# 手动测试提示函数
manual_test() {
    local name="$1"
    local instructions="$2"

    echo ""
    echo -e "${YELLOW}⚙️  手动测试:${NC} $name"
    echo "$instructions"
    echo ""
}

# 系统检查
echo -e "${BLUE}━━━ 第一部分：系统环境检查 ━━━${NC}"
echo ""

test_case "检查 macOS 系统" "test $(uname) = 'Darwin'" "true"
test_case "检查 terminal-notifier 安装" "command -v terminal-notifier" "false"
test_case "检查 say 命令可用" "command -v say" "true"
test_case "检查 jq 工具（用于 JSON 验证）" "command -v jq" "false"

echo ""

# 文件检查
echo -e "${BLUE}━━━ 第二部分：配置文件检查 ━━━${NC}"
echo ""

test_case "通知脚本存在" "test -f ~/.claude/scripts/notify.sh" "true"
test_case "通知脚本可执行" "test -x ~/.claude/scripts/notify.sh" "true"
test_case "settings.json 存在" "test -f ~/.claude/settings.json" "true"

# 验证 settings.json 格式
if command -v jq > /dev/null 2>&1; then
    test_case "settings.json 格式正确" "jq . ~/.claude/settings.json" "true"
fi

test_case "日志目录存在" "test -d ~/.claude/scripts" "true"

if test -f ~/.claude/scripts/notify.sh; then
    if grep -q -- "-group" ~/.claude/scripts/notify.sh; then
        echo -e "${YELLOW}⚠️  检测到 notify.sh 使用 -group 参数${NC}"
        echo "   可能导致通知互相替换，并出现 Removing previously sent notification"
        echo "   建议移除 -group，并过滤该提示信息"
        echo ""
    fi
fi

echo ""

# Hookify 规则检查
echo -e "${BLUE}━━━ 第三部分：Hookify 安全规则检查 ━━━${NC}"
echo ""

test_case "rm 安全规则文件存在" "test -f ~/.claude/hookify.voice-safety-rm.local.md" "false"
test_case "git 安全规则文件存在" "test -f ~/.claude/hookify.voice-safety-git.local.md" "false"
test_case "env 安全规则文件存在" "test -f ~/.claude/hookify.voice-safety-env.local.md" "false"

echo ""

# 通知脚本功能测试
echo -e "${BLUE}━━━ 第四部分：通知脚本功能测试 ━━━${NC}"
echo ""

if test -x ~/.claude/scripts/notify.sh; then
    echo "开始测试通知脚本的三个级别..."
    echo ""

    # Stop 级别测试
    echo -e "${BLUE}➤${NC} 测试 Stop 级别（无语音）"
    if ~/.claude/scripts/notify.sh '✅ Stop 测试' 'Stop 级别通知测试' '' 'stop' > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Stop 通知发送成功${NC}"
        echo -e "  ${YELLOW}请检查：桌面通知是否显示，是否播放 Pop 音，无语音${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}❌ Stop 通知发送失败${NC}"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("Stop 级别通知")
    fi
    TOTAL=$((TOTAL + 1))
    echo ""

    sleep 2

    # Input 级别测试
    echo -e "${BLUE}➤${NC} 测试 Input 级别（有语音）"
    if ~/.claude/scripts/notify.sh '🔔 Input 测试' 'Input 级别通知测试' '需要输入' 'input' > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Input 通知发送成功${NC}"
        echo -e "  ${YELLOW}请检查：桌面通知、Ping 音、语音播放1次${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}❌ Input 通知发送失败${NC}"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("Input 级别通知")
    fi
    TOTAL=$((TOTAL + 1))
    echo ""

    sleep 3

    # Error 级别测试
    echo -e "${BLUE}➤${NC} 测试 Error 级别（重复语音）"
    if ~/.claude/scripts/notify.sh '❌ Error 测试' 'Error 级别通知测试' '任务失败' 'error' > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Error 通知发送成功${NC}"
        echo -e "  ${YELLOW}请检查：桌面通知、Basso 音、语音播放2次${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}❌ Error 通知发送失败${NC}"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("Error 级别通知")
    fi
    TOTAL=$((TOTAL + 1))
    echo ""

    sleep 2

    # 中文语音测试
    echo -e "${BLUE}➤${NC} 测试中文语音识别"
    if ~/.claude/scripts/notify.sh '🇨🇳 中文测试' '中文语音测试' '任务已完成' 'input' > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ 中文语音测试发送成功${NC}"
        echo -e "  ${YELLOW}请检查：是否使用 Ting-Ting 语音${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}❌ 中文语音测试失败${NC}"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("中文语音识别")
    fi
    TOTAL=$((TOTAL + 1))
    echo ""

    sleep 3

    # 英文语音测试
    echo -e "${BLUE}➤${NC} 测试英文语音识别"
    if ~/.claude/scripts/notify.sh '🇺🇸 English Test' 'English voice test' 'Task completed' 'input' > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ 英文语音测试发送成功${NC}"
        echo -e "  ${YELLOW}请检查：是否使用 Alex 语音${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}❌ 英文语音测试失败${NC}"
        FAILED=$((FAILED + 1))
        FAILED_TESTS+=("英文语音识别")
    fi
    TOTAL=$((TOTAL + 1))
    echo ""
else
    echo -e "${RED}⚠️  通知脚本不可执行，跳过功能测试${NC}"
    echo ""
fi

# 日志检查
echo -e "${BLUE}━━━ 第五部分：日志验证 ━━━${NC}"
echo ""

if test -f ~/.claude/scripts/notify.log; then
    LOG_LINES=$(wc -l < ~/.claude/scripts/notify.log)
    echo -e "${GREEN}✅${NC} 日志文件存在，共 $LOG_LINES 行"
    echo ""
    echo "最近 5 条日志："
    echo -e "${YELLOW}─────────────────────────────────────────────────${NC}"
    tail -n 5 ~/.claude/scripts/notify.log 2>/dev/null || echo "（日志为空）"
    echo -e "${YELLOW}─────────────────────────────────────────────────${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️${NC}  日志文件尚未创建（首次运行后会自动创建）"
    echo ""
fi

# 语音测试提示
echo -e "${BLUE}━━━ 第六部分：语音能力验证 ━━━${NC}"
echo ""

echo "测试中文语音："
echo -e "${YELLOW}$ say -v Ting-Ting '测试中文语音'${NC}"
say -v "Ting-Ting" "测试中文语音" 2>/dev/null && echo -e "${GREEN}✅ 中文语音播放成功${NC}" || echo -e "${RED}❌ 中文语音不可用${NC}"
echo ""

sleep 2

echo "测试英文语音："
echo -e "${YELLOW}$ say -v Alex 'Testing English voice'${NC}"
say -v "Alex" "Testing English voice" 2>/dev/null && echo -e "${GREEN}✅ 英文语音播放成功${NC}" || echo -e "${RED}❌ 英文语音不可用${NC}"
echo ""

# 手动测试指南
echo -e "${BLUE}━━━ 第七部分：手动测试指南 ━━━${NC}"
echo ""

cat << 'EOF'
以下测试需要在 Claude Code 中手动执行：

1️⃣  Hookify 安全规则测试
   在 Claude Code 中输入：
   "请运行 rm -rf /tmp/test"

   期望：Hookify 拦截并提示警告

2️⃣  PostToolUse Hook 测试
   在 Claude Code 中输入：
   "运行一个会失败的命令: bash -c 'exit 1'"

   期望：收到 Error 通知，语音重复2次

3️⃣  Notification Hook 测试
   在 Claude Code 中输入：
   "请创建一个新文件 test.txt"

   期望：需要权限时收到 Input 通知

4️⃣  完整工作流测试
   使用语音输入（Typeless 或 macOS 听写）：
   "claude create a file named hello.txt with hello world"

   期望：任务完成后收到 Stop 通知
EOF

echo ""

# 测试总结
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}                    测试结果汇总${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "总计测试数: ${BLUE}$TOTAL${NC}"
echo -e "通过: ${GREEN}$PASSED${NC} ✅"
echo -e "失败: ${RED}$FAILED${NC} ❌"
echo -e "跳过: ${YELLOW}$SKIPPED${NC} ⚠️"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}失败的测试项：${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}✗${NC} $test"
    done
    echo ""
fi

# 配置建议
if [ $FAILED -gt 0 ] || [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}━━━ 配置建议 ━━━${NC}"
    echo ""

    if ! command -v terminal-notifier > /dev/null 2>&1; then
        echo -e "${YELLOW}📦${NC} 建议安装 terminal-notifier:"
        echo "   brew install terminal-notifier"
        echo ""
    fi

    if ! test -f ~/.claude/scripts/notify.sh; then
        echo -e "${YELLOW}📝${NC} 通知脚本缺失，请参考 README-实施指南.md 创建"
        echo ""
    fi

    if ! command -v jq > /dev/null 2>&1; then
        echo -e "${YELLOW}📦${NC} 建议安装 jq（用于 JSON 验证）:"
        echo "   brew install jq"
        echo ""
    fi
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 相关文档
echo "📚 相关文档："
echo "   - 快速开始: ./QUICK-START.md"
echo "   - 实施指南: ./README-实施指南.md"
echo "   - 完整测试用例: ./TEST-CASES.md"
echo ""

# 退出码
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}测试未完全通过，请检查失败项。${NC}"
    exit 1
else
    echo -e "${GREEN}所有必需测试已通过！🎉${NC}"
    exit 0
fi
