# ChatGPT/Codex Agent Config Templates

Claude Code以外のAIエージェント（ChatGPT、Codex等）向けの運用ガイドテンプレート。

## ファイル一覧

| テンプレート | 用途 | 置換変数 |
|-------------|------|---------|
| `agent.md.template` | 共通ルール（CLAUDE.md移植） | `${REPO_NAME}` |
| `agent.deploy.md.template` | デプロイ運用 | `${REPO_NAME}`, `${SITE_URL}` |
| `agent.research.md.template` | 調査運用 | `${REPO_NAME}` |
| `agent.writing.md.template` | 記事執筆品質 | `${REPO_NAME}`, `${CONTENT_LOCATION_RULE}`, `${CONTENT_SEARCH_PATH}` |

## 置換変数一覧

| 変数 | 説明 | 例 |
|------|------|-----|
| `${REPO_NAME}` | リポジトリ名 | `facility-safety` |
| `${SITE_URL}` | 本番サイトURL | `https://space-antenna.com/facility-safety/` |
| `${CONTENT_LOCATION_RULE}` | コンテンツ配置ルール | `ルート直下の *.qmd が公開対象。` |
| `${CONTENT_SEARCH_PATH}` | コンテンツ検索パス | `.` |

## デプロイ方法

`scripts/deploy.sh` の `-a` オプションで自動デプロイ:

```bash
# agent.*.md をリポジトリルートに生成
./scripts/deploy.sh -t -a /path/to/target-repo
```

## 設計方針

- **CLAUDE.mdが正本**: agent.*.mdはCLAUDE.mdのChatGPT/Codex向け移植
- **最小差分**: リポジトリ固有部分は変数置換のみ
- **段階的拡張**: 共通4本→プロジェクト固有追加は各リポジトリで
