#!/usr/bin/env bash
# transcript_work_check.sh
# Hook Type: PreToolUse
# Purpose: 文字起こし作業における禁止操作の検出・ブロック
# Trigger: Edit/Write ツール実行前
#
# 出力形式: exit 0 (許可) / exit 2 (ブロック)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)

# ツール名を取得
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Edit/Write以外はスルー
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# ファイルパスを取得
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 生データファイル（_raw.txt, _raw.md等）への書き込みをブロック
if echo "$FILE_PATH" | grep -qiE "_raw\.(txt|md)$"; then
  echo "生データファイルの編集は禁止されています。生データは原本として保持し、修正版は別ファイルとして新規作成してください。See: shared/rules/transcript-work.md" >&2
  exit 2
fi

# 生データファイルパターン2: raw_*.txt
if echo "$FILE_PATH" | grep -qiE "raw_[^/]+\.(txt|md)$"; then
  echo "生データファイル（raw_*）の編集は禁止されています。生データは原本として保持し、修正版は別ファイルとして新規作成してください。See: shared/rules/transcript-work.md" >&2
  exit 2
fi

# 統合操作の警告（複数のpartファイルを1つに統合しようとしている場合）
if [[ "$TOOL_NAME" == "Write" ]]; then
  if echo "$FILE_PATH" | grep -qiE "(merged|combined|統合|all_parts)"; then
    cat >&2 << 'MSG'
⚠️ ファイル統合操作を検出しました

**パート統合は禁止されています**

分割されたパートファイル（part1, part2, ...）は、分割された状態を維持してください。

**正しい対応**:
各パートごとに個別の修正版ファイルを作成：
- meeting_raw_part1.txt → meeting_part1.md
- meeting_raw_part2.txt → meeting_part2.md

See: shared/rules/transcript-work.md
MSG
    # additionalContext注入
    ESCAPED=$(printf '%s' "[transcript] パート統合は禁止です。各パートごとに個別の修正版ファイルを作成してください（例: meeting_raw_part1.txt → meeting_part1.md）。" | jq -Rs '.')
    echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}"
    # 警告のみ、ブロックしない
    exit 0
  fi
fi

# どのパターンにも該当しない場合はスルー
exit 0
