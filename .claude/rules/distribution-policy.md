# 配布ルール（Distribution Policy）

**優先度**: High
**適用範囲**: prompt-patternsからの全配布作業
**最終更新**: 2026-04-01

## 1. 概要

prompt-patternsは複数リポジトリへClaude Code環境（hooks, commands, skills, rules等）を配布する。
本文書は配布対象の判定、展開手順、保護機構を定義する。

## 2. リポジトリ分類

`scripts/repo-metadata.json` が全リポジトリの特性を管理する。

| フィールド | 型 | 説明 |
|-----------|------|------|
| `tools` | string[] | 使用ツール（quarto, python, npm, bibtex等） |
| `features` | string[] | 有効機能（memory-db, citation-check, preflight等） |
| `excluded` | bool | true = deploy.sh対象外 |
| `public` | bool | true = 公開リポジトリ |
| `notes` | string | 特記事項 |

**メタデータの更新**: 新リポ追加・ツール構成変更時に手動で更新する。

## 3. 配布対象の判定

以下の条件を**すべて**満たすリポジトリが配布対象:

1. `excluded` が false
2. `public` が false（`--allow-public`未指定時）
3. ローカルにディレクトリが存在する
4. `.claude/.no-deploy` マーカーが存在しない
5. Git remote所有者が Yaaasoh（フォークでない）

## 4. 展開の2経路

展開には**経路1（自動展開）**と**経路2（連絡展開）**の両方が必要。片方だけでは不完全。

| 経路 | 対象 | 手段 | 例 |
|------|------|------|-----|
| 経路1 | shared/配下（hooks, commands, skills, rules等） | `deploy.sh` | block_destructive.sh |
| 経路2 | 各リポジトリ固有情報（CLAUDE.md追記内容等） | `deployment-notices/` | UPDATE_20260401_*.md |

### deploy.sh のオプション

**単体展開**:
```bash
deploy.sh -t /path/to/repo      # 技術系パッケージ
deploy.sh -p /path/to/repo      # プロンプト作成パッケージ
deploy.sh -m /path/to/repo      # 最小構成
```

**一括展開**:
```bash
deploy.sh --all                  # 全リポ（technicalデフォルト）
deploy.sh --all --filter tools=quarto   # Quartoリポのみ
deploy.sh --all -n               # dry-run
deploy.sh --all --yes            # 確認プロンプトなし
```

### deployment-notices のファイル種別

| パターン | 用途 | 配布動作 |
|---------|------|---------|
| `UPDATE_YYYYMMDD_*.md` | 全リポ共通アップデート通知 | 常に上書き |
| `NOTICE_FOR_*.md` | リポ固有の導入案内 | 既存ならスキップ |
| `ACTION_*.md` | 対応が必要なアクション通知 | session_start.shに反映 |

## 5. 展開チェックリスト（順序厳守）

1. [ ] deployment-notices/にUPDATE/ACTIONファイルを**先に**作成（deploy.sh実行前）
2. [ ] deployment-notices/README.mdを更新
3. [ ] deploy.shで自動展開を実施（経路1）
4. [ ] CLAUDE.mdに追記すべき内容がないか確認
5. [ ] 全リポジトリのcommit+push（公開リポジトリ除外確認済み）
6. [ ] 展開結果のサマリーを確認（L7 Summary）

## 6. 保護レイヤー（L1〜L7）

| Layer | 保護内容 | 実装箇所 |
|:-----:|---------|---------|
| L1 | EXCLUDED_REPOS配列（ハードコード） | deploy.sh check_excluded_repo() |
| L2 | PUBLIC_REPOS配列（ハードコード） | deploy.sh check_public_repo() |
| L3 | フォーク検出（Yaaasoh以外ブロック） | deploy.sh check_fork_repo() |
| L4 | repo-metadata.json excluded=true（データ駆動） | resolve_all_targets() |
| L5 | --all時の確認プロンプト | deploy_all()（--yesまたは-nでスキップ） |
| L6 | `.claude/.no-deploy`マーカー | resolve_all_targets() |
| L7 | SKIPPEDサマリー表示 | show_skipped_summary() |

**L1-L3**: 単体・一括デプロイ両方で動作
**L4-L7**: `--all`モード専用（resolve_all_targets()内でL1チェックも二重実行）

**L1とL4の関係**: L1はdeploy.sh内のハードコード配列、L4はrepo-metadata.jsonのデータ。
リポジトリを除外する際は両方に登録すること（二重保護）。

## 7. ACTION_* 通知

### 仕様

ACTION_*.mdはYAML frontmatterで対象リポの条件を定義する:

```yaml
---
target_tools: [quarto, qmd]    # repo-metadata.jsonのtoolsとマッチ（インライン配列のみ）
target_features: []             # featuresとマッチ（空=条件なし）
action: required                # 将来拡張用（現在は未使用）
expires: 2026-05-01             # 期限YYYY-MM-DD（過ぎたら非表示）
---
```

**制約**: YAML配列はインライン形式 `[a, b]` のみ対応。ブロック形式（`- item`）は非対応。

### マッチングロジック

1. target_tools/target_featuresが両方空 → 全リポ対象
2. target_toolsにマッチするtoolがあれば対象
3. target_featuresにマッチするfeatureがあれば対象
4. expiresが過去日付なら非表示

### ライフサイクル

1. **作成**: deployment-notices/ACTION_*.mdとして配置
2. **配布**: deploy.sh実行時にsession_start.shに埋め込み（フルデプロイまたは`--category hooks`時のみ。`--only`や`--category rules`では更新されない）
3. **表示**: 対象リポのセッション開始時に通知（deploy_notices()による生ファイルコピーも同時に行われる）
4. **完了**: 対応完了後、expiresを過去日付にするか削除

## 8. 禁止事項

### 公開リポジトリへのデプロイ

**原則禁止**。`--allow-public`使用時も:
- .gitignoreに.claude/を追加必須
- リモートへのpush禁止

### フォークリポジトリ

**一切禁止**。ファイル追加・編集・コミット全て禁止。

### deploy.sh -f（force）

**ユーザーの明示的指示がある場合のみ**。
-fはリポジトリ固有カスタマイズを全て上書き破壊する。

### settings.json のhook迂回

settings.local.jsonでhooks空設定を追加してsettings.jsonのhookを迂回することは禁止。

---

## 関連ドキュメント

- `scripts/repo-metadata.json` — リポジトリメタデータ
- `scripts/deploy.sh` — 配布スクリプト
- `shared/rules/deployment.md` — デプロイ検証の汎用ルール（ヘルスチェック、完了基準）。本文書は配布ワークフロー固有の手順を定義
- `CLAUDE.md` — 展開チェックリスト（本文書のサブセット）
