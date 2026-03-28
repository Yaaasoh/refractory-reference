# バックアップ推奨連絡書

**発行日**: 2026-01-19
**発行元**: prompt-patterns
**対象**: 全リポジトリ
**優先度**: 中
**種別**: 予防保全

---

## 概要

2026-01-19にClaude CLI cli.jsファイル破損インシデントが発生しました。
全リポジトリの.claude設定ファイルについて、定期的なバックアップを推奨します。

## 発生したインシデント

| 問題 | 影響 |
|------|------|
| cli.js NULLバイト破損 | Claude CLI起動不可 |
| .claude.json破損リスク | 設定消失リスク |
| settings.json BOM問題 | JSON解析エラー |

**根本原因**: 自動更新の競合、レースコンディション、アンチウイルス干渉

## 推奨事項

### 1. バックアップ実施状況

本リポジトリの.claude設定は以下の場所にバックアップ済みです:

```
C:\Users\xprin\.claude-backups\repos_20260119\<リポジトリ名>\
```

### 2. 今後の推奨運用

| 作業 | 頻度 | 備考 |
|------|------|------|
| ユーザー設定バックアップ | 週次 | `~/.claude/scripts/backup-config.ps1` |
| リポジトリ設定バックアップ | 月次 | 手動または自動化検討 |
| 健全性チェック | 問題発生時 | `~/.claude/scripts/health-check.ps1` |

### 3. 復旧方法（参考）

設定が破損した場合:

```bash
# バックアップから復元
cp -r ~/.claude-backups/repos_20260119/<リポジトリ名>/* .claude/
```

## 対応

この連絡書は**情報共有**のためのものです。
特に対応は不要ですが、内容を確認後、この連絡書を削除してください。

### 確認後の対応

1. 内容を確認
2. 必要に応じてバックアップ場所をメモ
3. この連絡書を削除
4. コミット（任意）

## 関連ドキュメント

- [prompt-patterns] `work/reports/WORK_REPORT_20260119_BACKUP_IMPLEMENTATION.md`
- [prompt-patterns] `work/reports/WORK_REPORT_20260119_FILE_CORRUPTION_COUNTERMEASURES.md`

## 問い合わせ先

- **発行元リポジトリ**: prompt-patterns
- **関連PR**: #18

---

**対応完了後、この連絡書を削除してください**
