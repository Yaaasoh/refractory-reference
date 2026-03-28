#!/bin/bash
# typescript-quality-gate.sh - TypeScript品質ゲート
#
# 用途: Stop イベントで実行（ターン終了時の総合チェック）
# 効果: 型チェック・Lint・テストの自動実行
#
# 設定例 (.claude/settings.json):
# {
#   "hooks": {
#     "Stop": [{
#       "matcher": "",
#       "hooks": [{"type": "command", "command": ".claude/hooks/typescript-quality-gate.sh"}]
#     }]
#   }
# }

set -euo pipefail

echo "============================================" >&2
echo "  TypeScript Quality Gate" >&2
echo "============================================" >&2

ERRORS=0

# =============================================================================
# Step 1: 型チェック
# =============================================================================
echo "" >&2
echo "[1/3] Running type check (tsc --noEmit)..." >&2

TSC_OUTPUT=$(npx tsc --noEmit 2>&1) || true
TSC_EXIT=$?

if [ $TSC_EXIT -ne 0 ]; then
  echo "  ❌ 型エラーを検出しました" >&2
  echo "" >&2
  echo "$TSC_OUTPUT" | head -30 >&2
  echo "" >&2
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ 型チェック通過" >&2
fi

# =============================================================================
# Step 2: ESLint
# =============================================================================
echo "" >&2
echo "[2/3] Running ESLint..." >&2

# src/ が存在しない場合はスキップ
if [ -d "src" ]; then
  LINT_OUTPUT=$(npx eslint src/ --max-warnings 0 2>&1) || true
  LINT_EXIT=$?

  if [ $LINT_EXIT -ne 0 ]; then
    echo "  ❌ Lintエラーを検出しました" >&2
    echo "" >&2
    echo "$LINT_OUTPUT" | head -20 >&2
    echo "" >&2
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✓ Lint通過" >&2
  fi
else
  echo "  ⏭ src/ ディレクトリが存在しないためスキップ" >&2
fi

# =============================================================================
# Step 3: テスト（変更されたファイルに関連するもののみ）
# =============================================================================
echo "" >&2
echo "[3/3] Running related tests..." >&2

# package.jsonにtestスクリプトがあるか確認
if grep -q '"test"' package.json 2>/dev/null; then
  # Vitestの場合: related オプションを使用
  if grep -q "vitest" package.json 2>/dev/null; then
    TEST_OUTPUT=$(npx vitest related --run 2>&1) || true
    TEST_EXIT=$?
  else
    # Jestの場合
    TEST_OUTPUT=$(npm test -- --changedSince=HEAD~1 2>&1) || true
    TEST_EXIT=$?
  fi

  if [ $TEST_EXIT -ne 0 ]; then
    echo "  ❌ テスト失敗" >&2
    echo "" >&2
    echo "$TEST_OUTPUT" | tail -30 >&2
    echo "" >&2
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✓ テスト通過" >&2
  fi
else
  echo "  ⏭ testスクリプトが定義されていないためスキップ" >&2
fi

# =============================================================================
# 結果サマリー
# =============================================================================
echo "" >&2
echo "============================================" >&2

if [ $ERRORS -eq 0 ]; then
  echo "  ✅ Quality Gate Passed" >&2
  echo "============================================" >&2
  exit 0
else
  echo "  ❌ Quality Gate Failed ($ERRORS errors)" >&2
  echo "" >&2
  echo "t-wadaの教え:" >&2
  echo "  「動作するきれいなコード」がゴール" >&2
  echo "  - まず「動作する」を達成" >&2
  echo "  - 次に「きれい」にする" >&2
  echo "============================================" >&2
  exit 2
fi
