#!/bin/bash
# check_websearch_saved.sh — Stop hook (command)
# WebSearch/WebFetch結果の保存義務を検査
#
# 旧実装: agent型 → 権限不足で失敗（Read/Bash denied）
# 新実装: command型 → bashスクリプトで直接transcript解析
#
# ロジック:
#   1. stop_hook_active=true → 即終了（無限ループ防止）
#   2. transcriptからWebSearch/WebFetch呼び出し回数をカウント
#   3. work/やsources/配下の保存ファイル数をカウント
#   4. 呼び出し回数 > 保存ファイル数 → 警告出力
#   5. 呼び出し0回 or 保存数十分 → 何も出力しない

INPUT=$(cat)

# 無限ループ防止
ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$ACTIVE" = "true" ]; then
  exit 0
fi

# transcriptパスを取得
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
if [ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# WebSearch/WebFetch呼び出し回数をカウント
# transcriptはJSONL形式。tool_nameフィールドを検索
WS_COUNT=$(grep -c '"WebSearch"\|"WebFetch"' "$TRANSCRIPT" 2>/dev/null || true)
WS_COUNT=${WS_COUNT:-0}

# 呼び出し0回なら検査不要
if [ "$WS_COUNT" -eq 0 ] 2>/dev/null; then
  exit 0
fi

# tool_use行（呼び出し側）のみカウント（結果行を除外）
# tool_useのtool_nameを数える
CALL_COUNT=$(grep '"tool_name"' "$TRANSCRIPT" 2>/dev/null | grep -c '"WebSearch"\|"WebFetch"' || true)
CALL_COUNT=${CALL_COUNT:-0}

if [ "$CALL_COUNT" -eq 0 ] 2>/dev/null; then
  exit 0
fi

# cwdを取得
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
CWD=${CWD:-.}

# 保存ファイル数をカウント（work/とsources/配下の.txt/.mdファイル）
# セッション開始以降に変更されたファイルのみ対象にするのが理想だが、
# 簡易版として全ファイル数をカウント
SAVED_COUNT=0

# work/配下
if [ -d "$CWD/work" ]; then
  WORK_FILES=$(find "$CWD/work" -maxdepth 3 -name "*source*" -o -name "*search*" -o -name "*web*" 2>/dev/null | grep -cE '\.(txt|md)$' || true)
  SAVED_COUNT=$((SAVED_COUNT + ${WORK_FILES:-0}))
fi

# sources/配下
if [ -d "$CWD/sources" ]; then
  SRC_FILES=$(find "$CWD/sources" -name "*.txt" -o -name "*.md" 2>/dev/null | wc -l || true)
  SAVED_COUNT=$((SAVED_COUNT + ${SRC_FILES:-0}))
fi

# 比較: 呼び出し回数 > 保存ファイル数 なら警告
if [ "$CALL_COUNT" -gt "$SAVED_COUNT" ] 2>/dev/null; then
  echo "" >&2
  echo "========================================" >&2
  echo "【警告】WebSearch/WebFetch結果の未保存を検出" >&2
  echo "========================================" >&2
  echo "" >&2
  echo "  呼び出し回数: ${CALL_COUNT}回" >&2
  echo "  保存ファイル数: ${SAVED_COUNT}件" >&2
  echo "" >&2
  echo "  WebSearch結果は必ずファイルに保存してください" >&2
  echo "  保存先: work/ または sources/" >&2
  echo "========================================" >&2
  echo "" >&2
fi

exit 0
