#!/bin/bash
# ConfigChange Hook: settings.json改ざん検出
# INC-015対策: permissions.deny緩和、hooks削除をブロック
#
# 入力JSON:
#   source: user_settings / project_settings / local_settings / policy_settings / skills
#   file_path: 変更されたファイルパス
#
# exit 0: 許可
# exit 2: ブロック

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')

# policy_settingsはブロック不可（Enterprise管理）— 常に許可
if [ "$SOURCE" = "policy_settings" ]; then
  exit 0
fi

# skills変更は許可（スキルの追加・編集は正常運用）
if [ "$SOURCE" = "skills" ]; then
  exit 0
fi

# project_settings: permissions.deny と hooks の両方をチェック
if [ "$SOURCE" = "project_settings" ]; then
  if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
    # 1. permissions.deny が空になっていないかチェック
    DENY_COUNT=$(jq -r '.permissions.deny // [] | length' "$FILE_PATH" 2>/dev/null)
    if [ "$DENY_COUNT" = "0" ]; then
      echo "permissions.deny が空です。破壊的コマンドの禁止設定が削除された可能性があります。" >&2
      exit 2
    fi

    # 2. 必須deny項目の存在確認
    REQUIRED_DENIES=("rm -rf" "rm -r " "git clean" "git reset --hard")
    DENY_CONTENT=$(jq -r '.permissions.deny[]?' "$FILE_PATH" 2>/dev/null)
    for required in "${REQUIRED_DENIES[@]}"; do
      if ! echo "$DENY_CONTENT" | grep -q "$required"; then
        echo "permissions.deny に必須項目が不足: $required" >&2
        exit 2
      fi
    done

    # 3. hooks設定が空になっていないかチェック
    HOOKS_KEYS=$(jq -r '.hooks // {} | keys | length' "$FILE_PATH" 2>/dev/null)
    if [ "$HOOKS_KEYS" = "0" ]; then
      echo "hooks設定が空です。防御フックが削除された可能性があります。" >&2
      exit 2
    fi
  fi
fi

# local_settings: hooks迂回のみチェック（permissions.denyは通常project_settings側にある）
if [ "$SOURCE" = "local_settings" ]; then
  if [ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ]; then
    # hooks を空オブジェクトに上書きしていないか（settings.jsonのフックが迂回される）
    HAS_HOOKS_KEY=$(jq -r 'has("hooks")' "$FILE_PATH" 2>/dev/null)
    if [ "$HAS_HOOKS_KEY" = "true" ]; then
      HAS_EMPTY_HOOKS=$(jq -r 'if .hooks == {} then "yes" else "no" end' "$FILE_PATH" 2>/dev/null)
      if [ "$HAS_EMPTY_HOOKS" = "yes" ]; then
        echo "settings.local.json で hooks を空オブジェクトに設定することは禁止です（settings.json のフックが迂回されます）。" >&2
        exit 2
      fi
    fi
  fi
fi

# 許可
exit 0
