#!/usr/bin/env bash
# plan_mode_reminder.sh
# Hook Type: UserPromptSubmit
# Purpose: 大規模作業検出 → Plan Mode利用推奨
# Trigger: ユーザープロンプト送信時
#
# 出力形式: exit 0 (許可、リマインダー表示のみ)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

if [ -z "$PROMPT" ]; then
  exit 0
fi

# 大規模作業キーワード検出
if echo "$PROMPT" | grep -qiE "(リファクタリング|refactor|アーキテクチャ|architecture|全体.*変更|大規模|migration|移行|設計変更|redesign|全面.*改修|breaking.?change)"; then
  cat >&2 << 'MSG'
💡 大規模作業を検出しました。Plan Modeの利用を推奨します。

**Plan Mode起動**: Shift+Tab（2回）

**Plan Mode内で行うこと**:
1. Grep/Globで関連ファイルを特定
2. Readで既存コードを実際に読む
3. 読んだ事実に基づいて計画を作成

**計画の最小要件**: ファイルパス + 変更内容 + 根拠（読んだ事実）

See: .claude/rules/plan-mode.md
MSG
fi

exit 0
