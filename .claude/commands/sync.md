---
description: リモートリポジトリの進捗を確認
allowed-tools:
  - Bash
---

# リモートリポジトリ進捗確認

## 実行手順

### 1. リモートの最新情報を取得

```bash
git fetch --all
```

### 2. ローカルとリモートの状態確認

```bash
git status
```

確認ポイント:
- [ ] ローカルブランチがリモートより ahead/behind か
- [ ] 未コミットの変更があるか
- [ ] Untracked ファイルがあるか

### 3. リモートとの差分確認

リモートより ahead の場合（未プッシュのコミット）:
```bash
git log origin/main..HEAD --oneline
```

リモートより behind の場合（未取得のコミット）:
```bash
git log HEAD..origin/main --oneline
```

### 4. 結果サマリー

以下の形式で報告:

```
## 同期状態サマリー

| 項目 | 状態 |
|------|------|
| ブランチ | [現在のブランチ名] |
| ローカル vs リモート | ahead N / behind M |
| 未コミット変更 | あり/なし |
| Untracked ファイル | N 件 |

### 推奨アクション
- [次に実行すべきアクション]
```
