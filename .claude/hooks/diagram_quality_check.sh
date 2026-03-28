#!/bin/bash
# diagram_quality_check.sh - 図品質の軽量自動チェック (Quality Loops対応)
#
# 用途: PostToolUse (Write|Edit) で実行
# 効果: L1構文チェック + L2品質警告 + additionalContext修正指示注入
# 動作: stderr=人間向け警告、stdout=エージェント向けadditionalContext JSON
#
# 設定例 (.claude/settings.json):
# {
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Write|Edit",
#       "hooks": [{"type": "command", "command": "bash .claude/hooks/diagram_quality_check.sh", "timeout": 5}]
#     }]
#   }
# }

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# ファイルパスが空の場合はスルー
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 拡張子フィルタ: 図関連ファイルのみ処理
case "$FILE_PATH" in
  *.qmd|*.svg|*.mmd|*.dot) ;;
  *.html)
    # HTMLは図関連パターンを含む場合のみ
    if [ -f "$FILE_PATH" ]; then
      if ! grep -qE '(class="diagram"|class="flow"|<svg|mermaid)' "$FILE_PATH" 2>/dev/null; then
        exit 0
      fi
    else
      exit 0
    fi
    ;;
  *) exit 0 ;;
esac

# ファイルが存在しない場合はスルー
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

CONTENT=$(cat "$FILE_PATH")
WARNINGS=0
FIX_INSTRUCTIONS=""

# =============================================================================
# L1: 構文チェック
# =============================================================================

# Mermaidブロックの開閉チェック（.qmd, .html）
case "$FILE_PATH" in
  *.qmd|*.html)
    MERMAID_OPEN=$(echo "$CONTENT" | grep -c '```mermaid' || true)
    MERMAID_CLOSE=$(echo "$CONTENT" | grep -c '```$' || true)
    if [ "$MERMAID_OPEN" -gt 0 ] && [ "$MERMAID_CLOSE" -lt "$MERMAID_OPEN" ]; then
      echo "⚠️  L1構文: Mermaidブロックの閉じ忘れ（開: ${MERMAID_OPEN}, 閉じ候補: ${MERMAID_CLOSE}）" >&2
      FIX_INSTRUCTIONS="${FIX_INSTRUCTIONS}Mermaidブロックの閉じ忘れを修正してください（開: ${MERMAID_OPEN}, 閉じ: ${MERMAID_CLOSE}）。 "
      WARNINGS=$((WARNINGS + 1))
    fi
    ;;
esac

# SVGタグの開閉チェック
if echo "$CONTENT" | grep -q '<svg' ; then
  SVG_OPEN=$(echo "$CONTENT" | grep -c '<svg' || true)
  SVG_CLOSE=$(echo "$CONTENT" | grep -c '</svg>' || true)
  if [ "$SVG_OPEN" -ne "$SVG_CLOSE" ]; then
    echo "⚠️  L1構文: SVGタグ不一致（<svg: ${SVG_OPEN}, </svg>: ${SVG_CLOSE}）" >&2
    FIX_INSTRUCTIONS="${FIX_INSTRUCTIONS}SVGタグの開閉が不一致です（<svg: ${SVG_OPEN}, </svg>: ${SVG_CLOSE}）。閉じタグを追加してください。 "
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# =============================================================================
# L2: 品質警告
# =============================================================================

# 要素数チェック（9超で警告）
ELEMENT_COUNT=0
case "$FILE_PATH" in
  *.mmd|*.qmd)
    # Mermaidノード数: ID[label], ID(label), ID{label} パターン
    ELEMENT_COUNT=$(echo "$CONTENT" | grep -cE '^\s*[A-Za-z_][A-Za-z0-9_]*\s*[\[\(\{]' || true)
    ;;
  *.svg)
    # SVG主要図形数
    ELEMENT_COUNT=$(echo "$CONTENT" | grep -coE '<(rect|circle|ellipse|polygon|path) ' || true)
    ;;
  *.html)
    if echo "$CONTENT" | grep -q '<svg'; then
      ELEMENT_COUNT=$(echo "$CONTENT" | grep -coE '<(rect|circle|ellipse|polygon|path) ' || true)
    fi
    ;;
esac

if [ "$ELEMENT_COUNT" -gt 9 ]; then
  echo "⚠️  L2品質: 要素数が${ELEMENT_COUNT}個（推奨: 9以下）。図の分割を検討してください" >&2
  FIX_INSTRUCTIONS="${FIX_INSTRUCTIONS}要素数が${ELEMENT_COUNT}個です（推奨9以下）。図を分割してください。 "
  WARNINGS=$((WARNINGS + 1))
fi

# CSS変数未使用チェック: ハードコード色が3個以上 & var(--なし
HEX_COUNT=$(echo "$CONTENT" | grep -coE '#[0-9a-fA-F]{6}' || true)
VAR_COUNT=$(echo "$CONTENT" | grep -coE 'var\(--' || true)
if [ "$HEX_COUNT" -ge 3 ] && [ "$VAR_COUNT" -eq 0 ]; then
  HARDCODED_COLORS=$(echo "$CONTENT" | grep -oE '#[0-9a-fA-F]{6}' | sort -u | head -5 | tr '\n' ' ')
  echo "⚠️  L2品質: ハードコード色${HEX_COUNT}個、CSS変数未使用。色ドリフト防止にCSS変数を推奨" >&2
  FIX_INSTRUCTIONS="${FIX_INSTRUCTIONS}ハードコード色(${HARDCODED_COLORS})をCSS変数(例: var(--color-primary))に置き換えてください。 "
  WARNINGS=$((WARNINGS + 1))
fi

# viewBox未指定チェック（SVG）
case "$FILE_PATH" in
  *.svg)
    if echo "$CONTENT" | grep -q '<svg' && ! echo "$CONTENT" | grep -q 'viewBox'; then
      echo "⚠️  L2品質: SVGにviewBoxが未指定。レスポンシブ表示に問題が生じる可能性" >&2
      FIX_INSTRUCTIONS="${FIX_INSTRUCTIONS}<svg>タグにviewBox属性を追加してください（例: viewBox=\"0 0 800 600\"）。 "
      WARNINGS=$((WARNINGS + 1))
    fi
    ;;
esac

# 警告サマリ
if [ "$WARNINGS" -gt 0 ]; then
  echo "" >&2
  echo "📐 図品質チェック: ${WARNINGS}件の警告（${FILE_PATH}）" >&2
  echo "   詳細: .claude/rules/diagram-generation.md" >&2

  # additionalContext注入: エージェントのコンテキストに修正指示を注入
  # jqでJSON安全にエスケープし、明示的にfd1(stdout)に出力
  CONTEXT_TEXT="[図品質チェック] ${FILE_PATH} に${WARNINGS}件の問題: ${FIX_INSTRUCTIONS}"
  ESCAPED=$(printf '%s' "$CONTEXT_TEXT" | jq -Rs '.')
  echo "{\"hookSpecificOutput\":{\"additionalContext\":${ESCAPED}}}" >&1
fi

# 常にexit 0（警告のみ、ブロックしない）
exit 0
