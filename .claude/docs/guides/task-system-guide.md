# Task System活用ガイド

## 概要

Claude CodeのTask System（TodoWrite/TaskCreate/TaskUpdate/TaskList）を活用し、セッション間でタスクを永続化する方法。

## Task System永続化の設定

### 設定方法

`.claude/settings.json`に以下を追加：

```json
{
  "env": {
    "CLAUDE_CODE_TASK_LIST_ID": "your-project-name"
  }
}
```

### タスク保存先

```
~/.claude/tasks/{CLAUDE_CODE_TASK_LIST_ID}/
```

### 重要な注意

- **リポジトリごとに固有のIDを設定**すること
- 同じIDを使うと、異なるリポジトリのタスクが混在する
- 例: `vibration-diagnosis`, `tech-articles`, `prompt-patterns`

## 運用ルール

| 場面 | 対応 |
|------|------|
| 3ステップ以上の作業 | TaskCreateでタスク作成 |
| 作業開始時 | TaskUpdate → in_progress |
| 作業完了時 | TaskUpdate → completed |
| セッション終了時 | TaskListで残タスク確認 |

## 基本操作

### タスク作成

```
TaskCreate:
  subject: "ログイン機能のバグ修正"
  description: "認証エラー時にセッションがクリアされない問題を修正"
  activeForm: "Fixing login bug"
```

### タスク一覧確認

```
TaskList
```

### タスク更新

```
TaskUpdate:
  taskId: "1"
  status: "in_progress"
```

### タスク完了

```
TaskUpdate:
  taskId: "1"
  status: "completed"
```

## 活用シーン

### 1. 複数日にわたる作業

セッション終了時にタスク状態を保存し、次回セッションで継続。

### 2. 複雑なマルチステップ作業

依存関係を設定してタスクを管理。

```
TaskUpdate:
  taskId: "2"
  addBlockedBy: ["1"]
```

### 3. 調査・分析作業

段階的な調査をタスクとして管理。

## 参考

- [Task System解説（@nummanali）](https://x.com/nummanali)
- Claude Code公式ドキュメント

---

**最終更新**: 2026-01-25
