#!/usr/bin/env bash
# prevent_false_completion.sh
# Hook Type: UserPromptSubmit
# Purpose: 偽完了報告（FP-7）の防止
# Trigger: ユーザープロンプト送信時
#
# 出力形式: exit 0 (許可) / exit 2 (ブロック)
# メッセージ: stderr → ユーザーに表示

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# プロンプトが空の場合はスルー
if [ -z "$PROMPT" ]; then
  exit 0
fi

# 完了報告キーワードを検出
if echo "$PROMPT" | grep -qiE "(完了|done|finished|completed|終わり|終了|できた|できました|作成しました|実装しました|修正しました)"; then

  # 図変更の視覚検証チェック（一般検証とは独立して実行）
  DIAGRAM_CHANGED=false
  if git diff --name-only HEAD 2>/dev/null | grep -qE '\.(qmd|svg|mmd|dot)$'; then
    DIAGRAM_CHANGED=true
  elif git diff HEAD 2>/dev/null | grep -qE '(```mermaid|<svg|class="diagram"|class="flow"|mermaid)'; then
    DIAGRAM_CHANGED=true
  fi

  if [ "$DIAGRAM_CHANGED" = true ]; then
    if ! echo "$PROMPT" | grep -qiE "(スクリーンショット|screenshot|視覚検証|visual.?verif|ブラウザ確認|render|プレビュー|preview|表示確認|目視|CRAP|diagram-verifier)"; then
      cat >&2 << 'DIAGRAM_MSG'
⚠️ 図の変更を検出しましたが、視覚検証の証拠がありません

**図品質検証チェックリスト**:
- [ ] ブラウザでプレビューして表示を確認した
- [ ] スクリーンショットを取得した
- [ ] CRAP原則（Contrast/Repetition/Alignment/Proximity）を確認した
- [ ] 要素数が9以下であることを確認した

**推奨**: diagram-verifierサブエージェントでレビュー可能です

See: .claude/rules/diagram-generation.md
DIAGRAM_MSG
    fi
  fi

  # 検証証拠キーワードをチェック（一般検証）
  if echo "$PROMPT" | grep -qiE "(確認|verify|verified|テスト|test|検証|チェック|check|動作確認|パス|passed|成功|成果物|ファイル.*件|エラー.*0|警告.*0)"; then
    exit 0
  fi

  # 一般検証証拠がない場合、警告を表示
  cat >&2 << 'MSG'
⚠️ 完了報告を検出しましたが、検証証拠が確認できません

**偽完了報告防止（FP-7対策）**

完了報告には以下の証拠を含めてください：

**技術系作業の場合**:
- [ ] テスト結果（パス/失敗数）
- [ ] 動作確認結果
- [ ] エラー・警告の有無

**文字起こし修正の場合**:
- [ ] 修正したファイル一覧
- [ ] 修正箇所の具体的な数
- [ ] 品質確認結果（誤変換修正、時系列整合性等）

See: .claude/rules/task-integrity.md
MSG
  exit 0
fi

# 「準備完了」パターンの検出（INC-013対策）
if echo "$PROMPT" | grep -qiE "(準備完了|準備できた|準備OK|ready|準備が整った)"; then

  if echo "$PROMPT" | grep -qiE "(過去.*確認|ファイル.*確認|フォルダ.*確認|パターン.*確認|成果物.*確認|分割.*確認)"; then
    exit 0
  fi

  cat >&2 << 'MSG'
⚠️ 準備完了報告を検出しましたが、Phase 0確認の証拠がありません

**Phase 0: 過去成果物確認（必須）**

作業開始前に以下を確認してください：

1. [ ] 過去の成果物（生データ、修正版）を確認した
2. [ ] ファイルパターン（命名規則、分割基準）を確認した
3. [ ] フォルダ構成を確認した

See: .claude/skills/example-transcript-correction/workflow.md
MSG
  exit 0
fi

# どのパターンにも該当しない場合はスルー
exit 0
