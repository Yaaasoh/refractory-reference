#!/bin/bash
# R12: deploy.sh実行後にdeployment-notices/の更新を検証
# PostToolUse Bash で実行（if: Bash(*/deploy.sh *)）

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# deploy.shコマンドか確認
if ! echo "$COMMAND" | grep -q 'deploy\.sh'; then
    exit 0
fi

# deploy.shの実行が成功したか（exit_codeチェック）
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // .tool_response.exitCode // "0"')
if [ "$EXIT_CODE" != "0" ]; then
    exit 0  # 失敗したデプロイは警告不要
fi

echo ""
echo "========================================"
echo "⚠️ deploy.sh実行を検出しました（経路1完了）"
echo "========================================"
echo ""
echo "【経路2: 連絡展開の確認】"
echo "  deployment-notices/ にUPDATEファイルを作成しましたか？"
echo "  CLAUDE.mdへの追記推奨内容があれば連絡書が必要です。"
echo ""
echo "  展開は2経路の両方を実施して初めて完了です:"
echo "    経路1: deploy.sh（自動展開）← 実行済み"
echo "    経路2: deployment-notices/（連絡展開）← 要確認"
echo ""
echo "========================================"

exit 0
