#!/usr/bin/env bash
# quality_check.sh
# Hook Type: PreToolUse (Edit, Write)
# Purpose: テスト・lint改ざん検出（FP-1対策）
# Trigger: Edit/Writeツール実行前

set -euo pipefail

# JSON入出力（jqが必要）
INPUT=$(cat)

# 入力JSONから情報を抽出
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // ""')

# ツールがEdit/Writeでない場合はスルー
if [ "$TOOL" != "Edit" ] && [ "$TOOL" != "Write" ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# テスト・設定ファイルのパターン
PROTECTED_PATTERNS=(
  "test.*\\.py$"
  "test.*\\.js$"
  "test.*\\.ts$"
  ".*\\.test\\.py$"
  ".*\\.test\\.js$"
  ".*\\.test\\.ts$"
  ".*\\.spec\\.py$"
  ".*\\.spec\\.js$"
  ".*\\.spec\\.ts$"
  "\\.eslintrc"
  "\\.pylintrc"
  "pytest\\.ini$"
  "jest\\.config"
  "\\.github/workflows/.*\\.yml$"
  "\\.github/workflows/.*\\.yaml$"
  "\\.gitlab-ci\\.yml$"
)

# 保護対象ファイルかチェック
IS_PROTECTED=false
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qE "$pattern"; then
    IS_PROTECTED=true
    break
  fi
done

# 保護対象でない場合はスルー
if [ "$IS_PROTECTED" = false ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# 保護対象ファイルの場合は警告（ブロックはしない）
MESSAGE="⚠️ Quality Check Warning (FP-1)

You are about to modify a protected file:
File: $FILE_PATH

**Protected File Types**:
- Test files (test_*.py, *.test.js, *.spec.ts)
- Lint configuration (.eslintrc, .pylintrc, pytest.ini)
- CI/CD configuration (.github/workflows/*.yml, .gitlab-ci.yml)

**Anti-Tampering Rules** (shared/rules/anti-tampering-rules.md):

❌ **Prohibited Actions**:
- Weakening tests to make them pass
- Removing assertions or test cases
- Loosening lint rules to hide warnings
- Disabling CI checks

✅ **Correct Actions**:
- Fix implementation to pass tests (Fix Forward, Not Backward)
- Keep test strictness equal or stronger
- Fix code quality issues, don't hide them

**TDD Iron Law** (obra/superpowers):
> NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

**Question**: Are you modifying this file to:
A) Fix a bug in the test itself (OK if justified)
B) Weaken the test to make it pass (PROHIBITED)
C) Improve test coverage/quality (OK)

If B, please fix the implementation instead.

See: docs/rules/test.md - Anti-tampering Rules"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'

exit 0
