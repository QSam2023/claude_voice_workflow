#!/bin/bash
# ============================================================
# Claude Code 语音通知系统 - 综合测试脚本
# ============================================================
# 版本: 1.0
# 日期: 2026-01-20
# 用途: 全面测试语音通知、桌面通知、安全拦截流程
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

NOTIFY_SCRIPT="${HOME}/.claude/scripts/notify.sh"
SETTINGS_FILE="${HOME}/.claude/settings.json"
LOG_DIR="${HOME}/.claude/test-logs"
LOG_FILE="${LOG_DIR}/comprehensive_test_$(date +%Y%m%d_%H%M%S).log"
TEMP_DIR="/tmp/claude_voice_workflow_test_$$"

mkdir -p "$LOG_DIR"

SAY_AVAILABLE=true
HOOKIFY_CONFIGURED=false
RULES_LINKED=false

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

print_header() {
    log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${CYAN}$1${NC}"
    log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    log ""
    log "${BLUE}▶ $1${NC}"
    log "${BLUE}────────────────────────────────────────${NC}"
}

test_start() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    log "${YELLOW}[TEST-$TOTAL_TESTS]${NC} $1"
}

test_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    log "${GREEN}PASS${NC}: $1"
}

test_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    log "${RED}FAIL${NC}: $1"
}

test_skip() {
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    log "${MAGENTA}SKIP${NC}: $1"
}

run_check() {
    local name="$1"
    shift

    test_start "$name"
    if "$@"; then
        test_pass "$name"
        return 0
    fi

    test_fail "$name"
    return 1
}

manual_test() {
    local name="$1"
    local instructions="$2"

    test_start "$name"
    log "$instructions"
    test_skip "$name"
}

wait_for_seconds() {
    log "${YELLOW}等待 $1 秒以观察通知效果...${NC}"
    sleep "$1"
}

check_environment() {
    print_section "环境检查"

    if ! run_check "检查 notify.sh 脚本存在" test -f "$NOTIFY_SCRIPT"; then
        log "${RED}notify.sh 不存在，无法继续综合测试。${NC}"
        exit 1
    fi

    if ! run_check "检查 notify.sh 可执行" test -x "$NOTIFY_SCRIPT"; then
        log "${RED}notify.sh 无执行权限，请先 chmod +x。${NC}"
        exit 1
    fi

    if ! run_check "检查 settings.json 配置" test -f "$SETTINGS_FILE"; then
        log "${RED}settings.json 不存在，无法继续综合测试。${NC}"
        exit 1
    fi

    if ! run_check "检查 say 命令可用" command -v say > /dev/null 2>&1; then
        SAY_AVAILABLE=false
        log "${YELLOW}未检测到 say 命令，将跳过语音质量测试。${NC}"
    fi

    if command -v terminal-notifier > /dev/null 2>&1; then
        run_check "检查 terminal-notifier" command -v terminal-notifier > /dev/null 2>&1
    elif command -v osascript > /dev/null 2>&1; then
        run_check "检查 osascript" command -v osascript > /dev/null 2>&1
        log "${YELLOW}建议安装 terminal-notifier 以获得更好的通知体验。${NC}"
    else
        run_check "检查桌面通知工具" false
    fi

    if grep -q '"PreToolUse"' "$SETTINGS_FILE" 2>/dev/null; then
        HOOKIFY_CONFIGURED=true
    fi

    if ls -la .claude/hookify.*.local.md > /dev/null 2>&1; then
        RULES_LINKED=true
    fi

    mkdir -p "$LOG_DIR"
    mkdir -p "$TEMP_DIR"
}

test_notifications() {
    print_section "通知级别测试"

    test_start "Stop 级别通知"
    if "$NOTIFY_SCRIPT" "Stop 测试" "Stop 级别通知测试" "" "stop"; then
        test_pass "Stop 级别通知"
        log "请确认：桌面通知显示，Pop 音效，无语音。"
    else
        test_fail "Stop 级别通知"
    fi
    wait_for_seconds 2

    test_start "Input 级别通知"
    if "$NOTIFY_SCRIPT" "Input 测试" "Input 级别通知测试" "需要输入" "input"; then
        test_pass "Input 级别通知"
        log "请确认：桌面通知显示，Ping 音效，语音播放 1 次。"
    else
        test_fail "Input 级别通知"
    fi
    wait_for_seconds 2

    test_start "Error 级别通知"
    if "$NOTIFY_SCRIPT" "Error 测试" "Error 级别通知测试" "任务失败" "error"; then
        test_pass "Error 级别通知"
        log "请确认：桌面通知显示，Basso 音效，语音播放 2 次。"
    else
        test_fail "Error 级别通知"
    fi
    wait_for_seconds 3
}

test_voice_quality() {
    print_section "语音质量测试"

    if [ "$SAY_AVAILABLE" != true ]; then
        manual_test "语音质量测试" "缺少 say 命令，跳过语音测试。"
        return
    fi

    test_start "中文语音测试"
    if "$NOTIFY_SCRIPT" "中文测试" "中文语音测试" "任务已完成，请返回终端" "input"; then
        test_pass "中文语音测试"
        log "请确认：使用中文语音播报。"
    else
        test_fail "中文语音测试"
    fi
    wait_for_seconds 3

    test_start "英文语音测试"
    if "$NOTIFY_SCRIPT" "English Test" "English voice test" "Task completed" "input"; then
        test_pass "英文语音测试"
        log "请确认：使用英文语音播报。"
    else
        test_fail "英文语音测试"
    fi
    wait_for_seconds 3
}

test_hookify_manual() {
    print_section "Hookify 手动测试"

    if [ "$HOOKIFY_CONFIGURED" != true ]; then
        manual_test "Hookify 配置" "settings.json 未检测到 PreToolUse，跳过 Hookify 测试。"
        return
    fi

    if [ "$RULES_LINKED" != true ]; then
        manual_test "Hookify 规则链接" "未检测到 .claude 规则链接，请先建立符号链接。"
        return
    fi

    manual_test "拦截 rm -rf" "在 Claude Code 中输入：运行 rm -rf /tmp/test，期望被拦截。"
    manual_test "拦截 git push -f" "在 Claude Code 中输入：git push origin main --force，期望被拦截。"
    manual_test "警告 .env" "在 Claude Code 中输入：git add .env，期望发出警告。"
}

test_edge_cases() {
    print_section "边界情况测试"

    test_start "空语音内容"
    if "$NOTIFY_SCRIPT" "空语音" "仅桌面通知" "" "input"; then
        test_pass "空语音内容"
        log "请确认：无语音播报。"
    else
        test_fail "空语音内容"
    fi
    wait_for_seconds 2

    test_start "快速连续通知"
    "$NOTIFY_SCRIPT" "通知1" "第一条" "第一条" "input" &
    "$NOTIFY_SCRIPT" "通知2" "第二条" "第二条" "input" &
    "$NOTIFY_SCRIPT" "通知3" "第三条" "第三条" "input" &
    if wait; then
        test_pass "快速连续通知"
        log "请确认：终端无通知替换提示。"
    else
        test_fail "快速连续通知"
    fi
    wait_for_seconds 2
}

generate_report() {
    print_header "测试报告"

    local pass_rate=0
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        pass_rate=$(awk "BEGIN {printf \"%.1f\", ($PASSED_TESTS/$TOTAL_TESTS)*100}")
    fi

    log "总测试数: $TOTAL_TESTS"
    log "通过: $PASSED_TESTS"
    log "失败: $FAILED_TESTS"
    log "跳过: $SKIPPED_TESTS"
    log "通过率: ${pass_rate}%"
    log "日志文件: $LOG_FILE"

    if [ "$FAILED_TESTS" -eq 0 ]; then
        log "测试完成：无失败项。"
    else
        log "测试完成：存在失败项，请检查日志。"
    fi
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

main() {
    print_header "Claude Code 语音通知系统综合测试"
    log "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    log "日志文件: $LOG_FILE"

    trap cleanup EXIT

    check_environment
    test_notifications
    test_voice_quality
    test_hookify_manual
    test_edge_cases
    generate_report

    log "结束时间: $(date '+%Y-%m-%d %H:%M:%S')"

    if [ "$FAILED_TESTS" -eq 0 ]; then
        exit 0
    fi

    exit 1
}

main "$@"
