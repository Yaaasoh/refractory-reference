# UPDATE: Phase A hook基盤展開 (2026-04-01)

## 変更概要

Phase A（次世代改良企画）の全成果を展開しました。hook数 19→29件。

## 主な変更

### 1. block_destructive.sh改善
- `rm -r` 末尾一致パターン追加（`cd dir && rm -r .` の突破防止）
- Windowsコマンド4種（del, rmdir, rd, cmd.exe /c rd）のブロック追加
- `grep -qE` でパフォーマンス改善

### 2. protect_embeddings.sh if条件削除
- 安全系hookからif条件を削除（全Bash実行で評価）
- if条件は性能最適化であり安全性の代替ではない

### 3. R6 WebSearch保存義務hook — agent型→command型変換
- Stop hookのR6（WebSearch/WebFetch結果保存チェック）をcommand型に変更
- `check_websearch_saved.sh` 新規追加
- 変更理由: agent型Stop hookは権限制約（Read/Bash denied）で機能しなかった

### 4. 新規ルール・ポリシー
- `shared/rules/hook-if-condition-policy.md` — 安全系hookのif条件ポリシー

## CLAUDE.md追記推奨

特に追記は不要です。hook設定はsettings.jsonで自動適用されます。

## 参照
- `work/T2-1_stop_hook_test_results_20260331.md` — Stop hookテスト結果
- `shared/rules/hook-if-condition-policy.md` — if条件ポリシー
