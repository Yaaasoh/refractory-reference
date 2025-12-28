#!/usr/bin/env bash
# post_deploy_verification.sh
# Hook Type: PostToolUse (Bash)
# Purpose: デプロイコマンド後の検証を強制（FP-9対策）
# Trigger: Bashツール実行後

set -euo pipefail

# JSON入出力（jqが必要）
INPUT=$(cat)

# 入力JSONから情報を抽出
TOOL=$(echo "$INPUT" | jq -r '.tool // "unknown"')
COMMAND=$(echo "$INPUT" | jq -r '.command // ""')
EXIT_CODE=$(echo "$INPUT" | jq -r '.exit_code // 0')

# デプロイ関連コマンドのパターン
DEPLOY_PATTERNS=(
  "npm install"
  "pip install"
  "yarn install"
  "cargo install"
  "git clone"
  "git pull"
  "npm run build"
  "yarn build"
  "make install"
  "cp.*dist/"
  "rsync"
)

# デプロイコマンドかチェック
IS_DEPLOY=false
for pattern in "${DEPLOY_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    IS_DEPLOY=true
    break
  fi
done

# デプロイコマンドでない場合はスルー
if [ "$IS_DEPLOY" = false ]; then
  echo "$INPUT" | jq '{blocked: false}'
  exit 0
fi

# Exit codeが0でない場合は警告
if [ "$EXIT_CODE" -ne 0 ]; then
  MESSAGE="⚠️ Deployment Verification Warning (FP-9)

Deployment command failed (exit code: $EXIT_CODE)

Command: $COMMAND

**Required Actions** (deployment-verifier skill):
1. Check error messages and logs
2. Identify the root cause
3. Fix the issue
4. Re-run the command
5. Verify success (exit code 0)

**Do NOT** declare completion until:
✅ Command succeeds (exit code 0)
✅ Deployment verified (files exist, tests pass)

See: docs/rules/deployment.md - 4-Stage Verification"

  echo "$INPUT" | jq --arg msg "$MESSAGE" '{
    blocked: false,
    message: $msg
  }'
  exit 0
fi

# Exit codeが0の場合は検証リマインダー
MESSAGE="✅ Deployment Command Succeeded (exit code: 0)

Command: $COMMAND

**Post-Deployment Verification Required** (deployment-verifier skill):

□ Check deployed files exist
□ Check file permissions (if applicable)
□ Check dependencies installed (if applicable)
□ Run tests (if applicable)
□ Verify actual operation

**Do NOT** declare completion until verification is complete.

See: technical-projects-cli/.claude/skills/deployment-verifier/SKILL.md"

echo "$INPUT" | jq --arg msg "$MESSAGE" '{
  blocked: false,
  message: $msg
}'

exit 0
