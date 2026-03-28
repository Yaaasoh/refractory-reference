#!/usr/bin/env bash
# post_deploy_verification.sh
# Hook Type: PostToolUse (Bash)
# Purpose: デプロイコマンド後の検証を強制（FP-9対策）
# Trigger: Bashツール実行後
#
# 出力形式: exit 0 (許可) / exit 2 (ブロック)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)

# 入力JSONから情報を抽出（Claude Code v2.1+ 形式）
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Bashツールでない場合はスルー
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

# コマンドが空の場合はスルー
if [ -z "$COMMAND" ]; then
  exit 0
fi

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
  exit 0
fi

# デプロイコマンドを検出した場合は検証リマインダーを表示
cat >&2 << EOF
Post-Deployment Verification Required (FP-9)

Command: $COMMAND

Verify before declaring completion:
  1. Check deployed files exist
  2. Check file permissions (if applicable)
  3. Check dependencies installed (if applicable)
  4. Run tests (if applicable)
  5. Verify actual operation

Do NOT declare completion until verification is complete.

See: .claude/rules/deployment.md
EOF

# 警告のみ、ブロックしない
exit 0
