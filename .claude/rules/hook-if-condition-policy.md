# Hook if条件ポリシー

**対策対象**: INC-024（if条件の脆弱性による安全hookの迂回）
**優先度**: Critical
**出典**: codomon_memoriesセッション不始末分析（2026-03-30）

## 原則

**安全系hookにはif条件を原則設定しない。**

### 背景

Claude Code Hooksの`if`条件は**性能最適化**であり、**安全性の代替ではない**。

INC-024では、`protect_embeddings.sh`のif条件が`Bash(rm *.npy)|Bash(rm -* *.npy)`に限定されていたため、`cd dir && rm -r`パターンで迂回されてユーザー資産が消失した。

### if条件の設計判断基準

| 基準 | if条件 | 理由 |
|------|:------:|------|
| **迂回不可能**: ツール名と検査対象が1:1対応 | 設定可 | `git push`以外でfork pushは発生しない |
| **迂回可能**: コマンドの文字列パターンに依存 | **設定不可** | `cd && rm`等で突破可能 |
| **性能影響が軽微**: hookの実行時間が短い | 不要 | if条件なしでも体感差なし |

### 棚卸し結果（2026-03-31時点）

| Hook | if条件 | 判定 | 理由 |
|------|--------|:----:|------|
| `block_destructive.sh` | なし | OK | 全Bashコマンドをチェック（迂回防止） |
| `protect_embeddings.sh` | なし（削除済み） | OK | INC-024で脆弱性が判明、削除 |
| `python_path_guard.sh` | `Bash(python *)\|Bash(python3 *)` | **許容** | pythonコマンド以外で発火する意味がなく、迂回リスクも低い |
| `check_fork_push.sh` | `Bash(git push *)` | 許容 | git push以外でfork pushは不可能 |
| `deploy_force_guard` | `Bash(*/deploy.sh*-f*)` | 許容 | deploy.sh -f以外で発火する意味がない |
| `tdd-guard.sh` | `Edit(*.test.*)\|Write(*.test.*)` | 許容 | 品質系、テストファイル以外で発火不要 |

### 新規hookのif条件チェックリスト

新しいhookにif条件を設定する前に、以下を確認すること:

1. [ ] if条件がなくてもhookの実行時間は許容範囲か？（5秒以内）
2. [ ] if条件のパターンマッチを迂回する方法はないか？
3. [ ] hookスクリプト内部でツール名/コマンドを検査しているか？（内部検査があればif条件は冗長）
4. [ ] 安全系hookか品質系hookか？（安全系はif条件なしが原則）

## 関連

- `incidents/INC-024*.md` — if条件脆弱性の原因インシデント
- `shared/rules/hook-response-protocol.md` — Hook応答プロトコル
- `CLAUDE.md` 学習メモ 2026-03-29〜30 — 教訓

---

**最終更新**: 2026-03-31
**バージョン**: 1.0
