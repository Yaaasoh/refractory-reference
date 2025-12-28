#!/usr/bin/env bash
# auto_activate_skills.sh
# Hook Type: UserPromptSubmit
# Purpose: コンテキスト検出でSkill自動起動
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

# Skill起動メッセージを生成
generate_skill_message() {
  local skill_name="$1"
  local reason="$2"

  echo "🎯 Auto-Activating Skill: $skill_name

Reason: $reason

This skill will guide you through the process with best practices.

See: .claude/skills/$skill_name/SKILL.md"
}

# コンテキストパターンとSkillのマッピング

# code-quality-enforcer (FP-1, FP-2)
if echo "$PROMPT" | grep -qiE "(実装|implement|機能追加|add feature|バグ修正|fix bug|refactor|リファクタリング)"; then
  if echo "$PROMPT" | grep -qiE "(テスト|test)" || echo "$PROMPT" | grep -qivE "(テスト|test)"; then
    MESSAGE=$(generate_skill_message "code-quality-enforcer" "Implementation/bugfix/refactoring detected")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{
      blocked: false,
      message: $msg
    }'
    exit 0
  fi
fi

# deployment-verifier (FP-9)
if echo "$PROMPT" | grep -qiE "(デプロイ|deploy|インストール|install|ビルド|build|配備|npm install|pip install|git clone|git pull)"; then
  MESSAGE=$(generate_skill_message "deployment-verifier" "Deployment/installation command detected")
  echo "$INPUT" | jq --arg msg "$MESSAGE" '{
    blocked: false,
    message: $msg
  }'
  exit 0
fi

# purpose-driven-impl (FP-3)
if echo "$PROMPT" | grep -qiE "(新規|new|追加|add|作成|create)" && echo "$PROMPT" | grep -qiE "(機能|feature|プロジェクト|project|モジュール|module)"; then
  if ! echo "$PROMPT" | grep -qiE "(目的|purpose|なぜ|why|理由|reason)"; then
    MESSAGE=$(generate_skill_message "purpose-driven-impl" "New feature/project without clear purpose")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{
      blocked: false,
      message: $msg
    }'
    exit 0
  fi
fi

# root-cause-analyzer (FP-8)
if echo "$PROMPT" | grep -qiE "(エラー|error|問題|problem|バグ|bug|失敗|fail|動かない|not work)"; then
  if ! echo "$PROMPT" | grep -qiE "(確認|check|検証|verify|調査|investigate|ログ|log)"; then
    MESSAGE=$(generate_skill_message "root-cause-analyzer" "Error/problem reported without investigation")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{
      blocked: false,
      message: $msg
    }'
    exit 0
  fi
fi

# verification-enforcer (FP-10)
if echo "$PROMPT" | grep -qiE "(完了|complete|完成|finish|できました|done|作成しました|implemented)"; then
  if ! echo "$PROMPT" | grep -qiE "(テスト|test|確認|verify|検証|check)"; then
    MESSAGE=$(generate_skill_message "verification-enforcer" "Completion declared without verification evidence")
    echo "$INPUT" | jq --arg msg "$MESSAGE" '{
      blocked: false,
      message: $msg
    }'
    exit 0
  fi
fi

# どのパターンにも該当しない場合はスルー
echo "$INPUT" | jq '{blocked: false}'
exit 0
