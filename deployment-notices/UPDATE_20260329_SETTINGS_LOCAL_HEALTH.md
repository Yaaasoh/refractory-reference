# settings.local.json 健全性管理の導入

**日付**: 2026-03-29
**影響範囲**: 全リポジトリ
**対応の必要性**: 情報提供（即時対応不要）

---

## 概要

settings.local.jsonの健全性チェックを導入しました。
deploy.sh実行時およびaudit_repo_health.sh点検時に、settings.local.jsonの状態が自動的に報告されます。

## 導入された機能

### 1. deploy.sh 実行時の自動チェック

デプロイ時に以下を自動警告:
- settings.local.jsonがGit追跡されている場合（Critical）
- エントリ数が100件を超える場合（肥大化警告）

### 2. deploy.sh --verify の検証拡張

`deploy.sh --verify` 実行時に settings.local.json の状態を表示:
- .gitignore登録状況
- Git追跡状況
- エントリ数

### 3. audit_repo_health.sh の項目追加（項目8-10）

全リポ横断の健全性レポートに3項目を追加:
- 項目8: .gitignore登録（High）
- 項目9: Git追跡（Critical）
- 項目10: エントリ数（Medium、50件で警告/100件でエラー）

### 4. post_deploy_quality_check.sh の項目追加（項目6-8）

単一リポの品質チェックに3項目を追加:
- 項目6: .gitignore登録 + Git追跡チェック
- 項目7: deny/allow矛盾検出（settings.jsonのdenyとsettings.local.jsonのallowの突合）
- 項目8: エントリ数チェック

## settings.local.json について

settings.local.jsonはClaude Codeがセッション中に蓄積する許可設定です。

- **.gitignore登録必須**: 個人設定のため、Gitにコミットすべきではありません。deploy.shが自動で.gitignoreに追加します
- **肥大化**: 長期間使用するとallow/denyエントリが蓄積します。定期的な棚卸しを推奨します
- **deny/allow矛盾**: settings.jsonでdenyした項目がsettings.local.jsonのallowに存在する場合があります。意図的な場合（python全般禁止+特定pytest許可等）は問題ありませんが、post_deploy_quality_check.shで確認可能です

## 確認コマンド

```bash
# 単一リポの品質チェック
bash /path/to/prompt-patterns/scripts/post_deploy_quality_check.sh .

# 全リポの健全性レポート
bash /path/to/prompt-patterns/scripts/audit_repo_health.sh "C:/Users/xprin/github"
```

## ゴミエントリの除去

2026-03-29に全リポのsettings.local.jsonから不正エントリ（括弧なしの`WebSearch`等）を除去しました。バックアップが `.claude/settings.local.json.bak.*` に保存されています。

不要になったバックアップは手動で削除してください:
```bash
rm .claude/settings.local.json.bak.*
```
