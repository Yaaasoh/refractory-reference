# TodoWriteテンプレート

---
**出典**: session_2_3_task_todo_management.md 行548-606（付録）
**抽出日**: 2025-12-31
**SVCP観点**: Σ∃→Progress（進捗管理）
---

## 概要

TodoWriteツール使用時のタスク計画テンプレート。
Feature Development、Bug Fix、Research の3パターン。

---

## Feature Development

```markdown
## Feature: [機能名]

### Tasks
1. [ ] 設計確認
2. [ ] 関連コード調査
3. [ ] 実装: [コンポーネント1]
4. [ ] 実装: [コンポーネント2]
5. [ ] テスト作成
6. [ ] テスト実行・修正
7. [ ] ドキュメント更新
8. [ ] コミット

### Checkpoints
- CP1 (10min): 設計明確か？
- CP2 (30min): 主要機能動作か？
- CP3 (完了): 全テスト成功か？
```

---

## Bug Fix

```markdown
## Bug: [バグ概要]

### Tasks
1. [ ] バグ再現確認
2. [ ] 原因調査: [仮説1]
3. [ ] 原因調査: [仮説2]
4. [ ] 修正実装
5. [ ] 修正確認テスト
6. [ ] 回帰テスト
7. [ ] コミット

### Root Cause
[発見後に記載]
```

---

## Research

```markdown
## Research: [調査テーマ]

### Tasks
1. [ ] 公式ドキュメント調査
2. [ ] コミュニティ事例収集
3. [ ] [トピック1]調査
4. [ ] [トピック2]調査
5. [ ] 結果整理
6. [ ] 報告書作成
7. [ ] コミット

### Sources (100%保存義務)
- [ ] source1.md
- [ ] source2.md
```

---

## 使用方法

1. タスク開始時にTodoWriteでタスク登録
2. 作業開始時に該当タスクをin_progressに変更
3. 完了したら即座にcompletedに変更（バッチ不可）
4. Checkpointsで定期的に進捗確認

## 注意事項

- 同時にin_progressにできるのは1タスクのみ
- 8/80ルール: 8分〜80分の粒度を維持
- 30分ルール: 80%未達なら方針見直し
