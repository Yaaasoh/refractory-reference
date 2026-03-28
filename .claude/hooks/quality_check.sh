#!/usr/bin/env bash
# quality_check.sh
# Hook Type: PreToolUse (Edit, Write)
# Purpose: テスト・lint改ざん検出（FP-1対策）
# Trigger: Edit/Writeツール実行前
#
# 出力形式: exit 0 (許可) / exit 2 (ブロック)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)

# 入力JSONから情報を抽出（Claude Code v2.1+ 形式）
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# ツールがEdit/Writeでない場合はスルー
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
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
  exit 0
fi

# 保護対象ファイルの場合は警告（stderrに出力、ブロックはしない）
cat >&2 << EOF
Quality Check Warning (FP-1)

You are about to modify a protected file:
File: $FILE_PATH

Protected File Types:
- Test files (test_*.py, *.test.js, *.spec.ts)
- Lint configuration (.eslintrc, .pylintrc, pytest.ini)
- CI/CD configuration (.github/workflows/*.yml, .gitlab-ci.yml)

Anti-Tampering Rules (shared/rules/anti-tampering-rules.md):

Prohibited:
- Weakening tests to make them pass
- Removing assertions or test cases
- Loosening lint rules to hide warnings
- Disabling CI checks

Correct:
- Fix implementation to pass tests (Fix Forward, Not Backward)
- Keep test strictness equal or stronger

TDD Iron Law (obra/superpowers):
> NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

See: .claude/rules/anti-tampering-rules.md
EOF

# 警告のみ、ブロックしない
exit 0
