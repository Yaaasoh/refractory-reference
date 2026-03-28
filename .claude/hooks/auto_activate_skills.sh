#!/usr/bin/env bash
# auto_activate_skills.sh
# Hook Type: UserPromptSubmit
# Purpose: コンテキスト検出でSkill自動起動とリマインダー表示
# Trigger: ユーザープロンプト送信時
#
# 出力形式: exit 0 (許可) / exit 2 (ブロック)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# プロンプトが空の場合はスルー
if [ -z "$PROMPT" ]; then
  exit 0
fi

# transcript-correction (文字起こし修正)
if echo "$PROMPT" | grep -qiE "(文字起こし|transcript|議事録|会議録|校正.*会議|修正.*会議|OCR.*修正)"; then
  cat >&2 << 'MSG'
🎯 文字起こし修正作業を検出しました

**Phase 0: 過去成果物確認（必須）**
作業を開始する前に、以下を完了してください：

1. [ ] 文字起こしファイル格納フォルダを確認した
2. [ ] 過去の生データファイル（_raw.txt等）を最低1件確認した
3. [ ] 過去の修正版ファイル（.md）を最低1件確認した
4. [ ] ファイル分割パターン（part1-N）を確認した
5. [ ] 進捗報告書を確認した（存在する場合）

**絶対禁止**:
- 生データファイルの編集禁止
- パートの統合禁止
- 要約の作成禁止
- 「構造化」という用語の使用禁止

**Phase 0を完了せずに作業を開始すると、INC-013のような問題が再発します。**

See: .claude/skills/example-transcript-correction/SKILL.md
MSG
  exit 0
fi

# verification-enforcer (FP-10)
if echo "$PROMPT" | grep -qiE "(完了|complete|完成|finish|できました|done|作成しました|implemented)"; then
  if ! echo "$PROMPT" | grep -qiE "(テスト|test|確認|verify|検証|check)"; then
    echo "🎯 Auto-Activating Skill: verification-enforcer" >&2
    echo "Reason: Completion declared without verification evidence" >&2
    echo "See: .claude/skills/verification-enforcer/SKILL.md" >&2
    exit 0
  fi
fi

# どのパターンにも該当しない場合はスルー
exit 0
