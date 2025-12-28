#!/bin/bash
# セッション開始時の案内
# SessionStart hook

echo ""
echo "========================================"
echo "   prompt-patterns セッション開始"
echo "========================================"
echo ""
echo "【重要】このリポジトリでは破壊的コマンドが禁止されています。"
echo ""
echo "  禁止: rm -rf, git clean -fd, git reset --hard"
echo "  詳細: CLAUDE.md"
echo ""
echo "【パッケージ構成】"
echo "  - technical-projects-cli/     技術系（CLI向け）"
echo "  - prompt-creation-projects-cli/ プロンプト作成（CLI向け）"
echo ""
echo "【作業ディレクトリ】"
echo "  - 作業は work/ で行ってください"
echo "  - パッケージディレクトリは直接編集しないでください"
echo ""
echo "========================================"
echo ""
