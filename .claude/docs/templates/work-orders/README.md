# 作業連絡書（Work Orders）

**目的**: prompt-patternsからの設定更新・改善提案を各リポジトリで追跡・実施するためのフォルダ

---

## このフォルダについて

prompt-patternsリポジトリで調査・検討された改善事項が連絡書として配置されます。
各連絡書は対応完了後に削除してください。

## 連絡書の種類

| プレフィックス | 内容 | 例 |
|---------------|------|-----|
| `SETTINGS_UPDATE_*` | settings.json更新 | SETTINGS_UPDATE_NOTICE_202601.md |
| `HOOKS_UPDATE_*` | Hooks追加・更新 | HOOKS_UPDATE_NOTICE_202601.md |
| `CLAUDE_MD_*` | CLAUDE.md改善 | CLAUDE_MD_IMPROVEMENT_GUIDE.md |
| `SECURITY_*` | セキュリティ関連 | SECURITY_NOTICE_202601.md |

## 対応フロー

```
1. 連絡書を読む
2. 記載された手順に従って対応
3. 対応完了後、連絡書を削除
4. コミット
```

## 注意事項

- 連絡書は**対応完了後に削除**してください
- 削除忘れ防止のため、定期的にこのフォルダを確認してください
- 対応が不要な場合も、その旨をコミットメッセージに記載して削除してください

## 発行元

- **リポジトリ**: [prompt-patterns](https://github.com/Yaaasoh/prompt-patterns)
- **連絡書テンプレート**: `shared/docs/templates/work-orders/`

---

**最終更新**: 2026-01-18
