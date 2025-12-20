#!/bin/bash
# 用語集品質検証スクリプト
# 用途: 技術用語集の公開前品質チェック
# 使用法: ./validate_glossary.sh <対象ディレクトリ> [オプション]

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# スクリプトのディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_DIR="${SCRIPT_DIR}/patterns"

# デフォルト設定
TARGET_DIR="${1:-.}"
VERBOSE=false
OUTPUT_FILE=""

# ヘルプ表示
show_help() {
    echo "用語集品質検証スクリプト"
    echo ""
    echo "使用法: $0 <対象ディレクトリ> [オプション]"
    echo ""
    echo "オプション:"
    echo "  -v, --verbose    詳細出力"
    echo "  -o, --output     結果をファイルに出力"
    echo "  -h, --help       このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 ../           # 親ディレクトリの.mdファイルを検証"
    echo "  $0 ../ -v        # 詳細モードで検証"
}

# 引数解析
while [[ $# -gt 1 ]]; do
    case "$2" in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$3"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# 結果カウンター
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

# ログ関数
log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((WARN_COUNT++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

log_info() {
    echo -e "[INFO] $1"
}

# パターンファイルからgrepパターン生成
build_grep_pattern() {
    local pattern_file="$1"
    if [[ ! -f "$pattern_file" ]]; then
        echo ""
        return
    fi
    # コメント行と空行を除外してパターン結合
    grep -v '^#' "$pattern_file" | grep -v '^$' | grep -v '^##' | paste -sd '|' -
}

# ファイル検証
validate_files() {
    local target="$1"
    local files=$(find "$target" -maxdepth 1 -name "*.md" -type f 2>/dev/null | grep -v "validation/" | grep -v "DELETION_REPORT")

    if [[ -z "$files" ]]; then
        log_info "対象ファイルなし: $target"
        return
    fi

    local file_count=$(echo "$files" | wc -l)
    log_info "検証対象: ${file_count}ファイル"
    echo ""

    # === カテゴリA: 機密情報パターン ===
    echo "=== カテゴリA: 機密情報パターン ==="

    # A1: 企業名
    local company_pattern=$(build_grep_pattern "${PATTERNS_DIR}/companies.txt")
    if [[ -n "$company_pattern" ]]; then
        local company_matches=$(echo "$files" | xargs grep -l -E "$company_pattern" 2>/dev/null | wc -l)
        if [[ "$company_matches" -eq 0 ]]; then
            log_pass "企業名パターン: 0件検出"
        else
            log_fail "企業名パターン: ${company_matches}件検出"
            if $VERBOSE; then
                echo "$files" | xargs grep -n -E "$company_pattern" 2>/dev/null | head -10
            fi
        fi
    else
        log_warn "企業名パターンファイルなし"
    fi

    # A2: 人名（苗字）
    local surname_pattern=$(build_grep_pattern "${PATTERNS_DIR}/surnames.txt")
    if [[ -n "$surname_pattern" ]]; then
        # 苗字+敬称のパターンで検索（用語として使われている場合を除外）
        local surname_matches=$(echo "$files" | xargs grep -c -E "(${surname_pattern})(さん|氏|様)" 2>/dev/null | grep -v ":0$" | wc -l)
        if [[ "$surname_matches" -eq 0 ]]; then
            log_pass "人名パターン: 0件検出"
        else
            log_warn "人名パターン: ${surname_matches}件検出 → 要確認"
            if $VERBOSE; then
                echo "$files" | xargs grep -n -E "(${surname_pattern})(さん|氏|様)" 2>/dev/null | head -10
            fi
        fi
    else
        log_warn "人名パターンファイルなし"
    fi

    # A3: 識別子・敬称
    local id_matches=$(echo "$files" | xargs grep -c -E "OCR-[0-9]+|CASE-[0-9]+|社外秘|Confidential|機密" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$id_matches" -eq 0 ]]; then
        log_pass "識別子・機密マーカー: 0件検出"
    else
        log_fail "識別子・機密マーカー: ${id_matches}件検出"
        if $VERBOSE; then
            echo "$files" | xargs grep -n -E "OCR-[0-9]+|CASE-[0-9]+|社外秘|Confidential|機密" 2>/dev/null | head -10
        fi
    fi

    echo ""

    # === カテゴリB: 不適切コンテンツ ===
    echo "=== カテゴリB: 不適切コンテンツ ==="

    # B1: 仕様値・参考値（温度範囲）
    local temp_matches=$(echo "$files" | xargs grep -c -E "[0-9]+[〜\-][0-9]+℃" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$temp_matches" -eq 0 ]]; then
        log_pass "温度範囲: 0件検出"
    else
        log_warn "温度範囲: ${temp_matches}件検出 → 要確認"
        if $VERBOSE; then
            echo "$files" | xargs grep -n -E "[0-9]+[〜\-][0-9]+℃" 2>/dev/null | head -10
        fi
    fi

    # B1: 仕様値・参考値（寸法）
    local dim_matches=$(echo "$files" | xargs grep -c -E "[0-9]+[〜\-][0-9]+mm" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$dim_matches" -eq 0 ]]; then
        log_pass "寸法範囲: 0件検出"
    else
        log_warn "寸法範囲: ${dim_matches}件検出 → 要確認"
    fi

    # B2: 「参考値」「典型値」列
    local ref_matches=$(echo "$files" | xargs grep -c -E "\| *参考値 *\||\| *典型値 *\|" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$ref_matches" -eq 0 ]]; then
        log_pass "参考値/典型値列: 0件検出"
    else
        log_fail "参考値/典型値列: ${ref_matches}件検出"
        if $VERBOSE; then
            echo "$files" | xargs grep -n -E "\| *参考値 *\||\| *典型値 *\|" 2>/dev/null | head -10
        fi
    fi

    echo ""

    # === カテゴリC: データ品質 ===
    echo "=== カテゴリC: データ品質 ==="

    # C1: 文字化け
    local mojibake_matches=$(echo "$files" | xargs grep -c "�" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$mojibake_matches" -eq 0 ]]; then
        log_pass "文字化け: 0件検出"
    else
        log_fail "文字化け: ${mojibake_matches}件検出"
        if $VERBOSE; then
            echo "$files" | xargs grep -n "�" 2>/dev/null | head -10
        fi
    fi

    # C2: テーブル構造（基本チェック）
    local table_issues=$(echo "$files" | xargs grep -c "^\|[^|]*$" 2>/dev/null | grep -v ":0$" | wc -l)
    if [[ "$table_issues" -eq 0 ]]; then
        log_pass "テーブル構造: 問題なし"
    else
        log_warn "テーブル構造: ${table_issues}件要確認"
    fi

    echo ""
}

# サマリー表示
show_summary() {
    echo "=========================================="
    echo "検証サマリー"
    echo "=========================================="
    echo -e "${GREEN}PASS: ${PASS_COUNT}${NC}"
    echo -e "${YELLOW}WARN: ${WARN_COUNT}${NC}"
    echo -e "${RED}FAIL: ${FAIL_COUNT}${NC}"
    echo ""

    if [[ "$FAIL_COUNT" -gt 0 ]]; then
        echo -e "${RED}判定: FAIL - 修正が必要です${NC}"
        exit 1
    elif [[ "$WARN_COUNT" -gt 0 ]]; then
        echo -e "${YELLOW}判定: WARN - 確認が必要です${NC}"
        exit 0
    else
        echo -e "${GREEN}判定: PASS - 公開可能です${NC}"
        exit 0
    fi
}

# メイン処理
main() {
    echo "=========================================="
    echo "用語集品質検証"
    echo "対象: $TARGET_DIR"
    echo "実行日時: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""

    validate_files "$TARGET_DIR"
    show_summary
}

main
