#!/usr/bin/env bash
# prevent_false_completion.sh
# Hook Type: UserPromptSubmit
# Purpose: 偽完了報告の検出（FP-7対策）
# Trigger: ユーザープロンプト送信時

set -euo pipefail

# JSON入出力（jqが必要）
INPUT=$(cat)

# 入力JSONから情報を抽出
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# プロンプトが空の場合はスルー
if [ -z "$PROMPT" ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# 完了宣言のパターン
COMPLETION_PATTERNS=(
  "完了"
  "完成"
  "終了"
  "できました"
  "作成しました"
  "実装しました"
  "修正しました"
  "デプロイしました"
  "インストールしました"
  "completed"
  "finished"
  "done"
  "implemented"
  "deployed"
)

# 完了宣言が含まれているかチェック
HAS_COMPLETION=false
for pattern in "${COMPLETION_PATTERNS[@]}"; do
  if echo "$PROMPT" | grep -qi "$pattern"; then
    HAS_COMPLETION=true
    break
  fi
done

# 完了宣言でない場合はスルー
if [ "$HAS_COMPLETION" = false ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# 検証キーワードのチェック
VERIFICATION_KEYWORDS=(
  "テスト"
  "確認"
  "検証"
  "パス"
  "成功"
  "動作"
  "test"
  "verify"
  "check"
  "pass"
  "success"
  "works"
)

HAS_VERIFICATION=false
for keyword in "${VERIFICATION_KEYWORDS[@]}"; do
  if echo "$PROMPT" | grep -qi "$keyword"; then
    HAS_VERIFICATION=true
    break
  fi
done

# 検証証拠がある場合はOK
if [ "$HAS_VERIFICATION" = true ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# 完了宣言があるが検証証拠がない場合は警告
MESSAGE="⚠️ False Completion Warning (FP-7)

Your message contains completion keywords but lacks verification evidence.

**Completion keywords detected**:
$(echo "$PROMPT" | grep -oiE '(完了|完成|終了|できました|作成しました|実装しました|修正しました|デプロイしました|completed|finished|done|implemented|deployed)' | head -5)

**Missing verification evidence**:
No keywords found: テスト, 確認, 検証, パス, 成功, etc.

**Task Integrity Rules** (docs/rules/task-integrity.md):

**Honest Reporting Principle**:
- ✅ Report: \"Implemented X, tested with Y, all tests pass\"
- ❌ Report: \"Implemented X\" (no verification mentioned)

**Definition of Done**:
□ Implementation complete
□ Tests written
□ Tests executed
□ Tests pass
□ Verification complete
→ THEN declare completion

**Required Evidence**:
- Test results (e.g., \"pytest: 15 passed\")
- Verification logs (e.g., \"npm install: successfully installed\")
- Manual check results (e.g., \"confirmed file exists\")

**Question**: Have you completed verification?
- If YES: Please add verification evidence to your message
- If NO: Complete verification first, then report

See: docs/rules/task-integrity.md - Honest Reporting"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'

exit 0
