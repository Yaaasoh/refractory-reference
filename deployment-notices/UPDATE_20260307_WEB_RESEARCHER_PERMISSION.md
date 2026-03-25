# UPDATE: web-researcher サブエージェント permissionMode 修正

**日付**: 2026-03-07
**種別**: バグ修正（Critical）
**対象**: 全リポジトリ（自動展開済み）

## 概要

web-researcher サブエージェントに `permissionMode: acceptEdits` を追加しました。

## 問題

バックグラウンドで実行されるサブエージェント（Agent ツール経由）は、ユーザーに許可プロンプトを表示できません。
そのため、Write ツールが即座に拒否され、調査結果のファイル保存が全て失敗していました。

### 根本原因

Claude Code の仕様として、バックグラウンドエージェントは許可プロンプトを表示する手段がなく、
許可されていないツールの呼び出しは「許可待ち」ではなく「即時拒否」されます。

## 修正内容

`.claude/agents/web-researcher.md` のフロントマターに以下を追加:

```yaml
permissionMode: acceptEdits
```

これにより、Write/Edit ツールの使用が自動承認され、サブエージェントが調査結果をファイルに保存できるようになります。

### 同時修正

- `model: haiku` を削除（デフォルトモデルを使用）
- read-only エージェント（code-reviewer, codebase-explorer）に `disallowedTools` を追加し、仕様レベルで書き込みを禁止

## CLAUDE.md への推奨追記

特に追記不要です。エージェント定義ファイルの変更のみで対応完了しています。

## 確認方法

```bash
# web-researcher に permissionMode が設定されていることを確認
grep "permissionMode" .claude/agents/web-researcher.md
# 期待出力: permissionMode: acceptEdits
```

## 影響

- web-researcher サブエージェントが正常にファイル保存可能になります
- 調査タスクをサブエージェントに委譲した際のファイル書き込み失敗が解消されます
