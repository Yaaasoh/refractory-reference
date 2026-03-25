# UPDATE: .gitattributes の *.txt 設定修正（改行変換問題対策）

**日付**: 2026-03-18
**重要度**: 高（障害対応）
**影響**: 全デプロイ対象リポジトリ

---

## 概要

`.gitattributes` の `*.txt` および `*.csv` 設定を修正しました。
CP932等の非UTF-8テキストファイルと改行変換設定の衝突を防止します。

## 背景（pst_dev_docsでの障害）

- Word出力のCP932テキストファイル（CR/LF/CRLF混在）が存在
- `*.txt text eol=lf encoding=UTF-8` 設定により、checkout時に不正な改行変換が発生
- `git pull` がブロックされ、`stash`/`checkout --`でも解消不可能になった

## 変更内容

```gitattributes
# 変更前（問題あり）
*.txt text eol=lf encoding=UTF-8
*.csv text eol=lf encoding=UTF-8

# 変更後（安全）
*.txt text=auto eol=lf
*.csv text=auto eol=lf
```

**変更のポイント**:
- `text=auto`: gitがファイル内容からテキスト/バイナリを自動判定
- CP932ファイルはバイナリ判定される可能性が高く、改行変換がスキップされる
- `encoding=UTF-8` を削除: 実験的機能であり非UTF-8ファイルと衝突する
- UTF-8の .txt/.csv は引き続きLF正規化される

## 必要なアクション

### 全リポジトリ共通

1. `.gitattributes` を更新版に差し替え（次回deploy.sh実行時に自動適用）
2. 差し替え後、以下を実行してインデックスを再構築:
   ```bash
   git rm --cached -r .
   git reset HEAD .
   git checkout -- .
   ```

### pst_dev_docs 固有

既に障害が発生しているCP932ファイルについて、追加で以下を `.gitattributes` に記載:

```gitattributes
# CP932テキストファイル（改行変換を完全無効化）
docs/technical_docs/inspection_tech/260317_*.txt -text diff
docs/technical_docs/inspection_tech/report_2025_v09/260317_*.txt -text diff
```

## 教訓

1. `*.txt text eol=lf encoding=UTF-8` は全.txtがUTF-8である前提の設定
2. 日本語環境ではWord出力等でCP932の.txtが頻出する
3. `encoding=UTF-8` はgitの実験的機能であり、本番利用は避けるべき
4. デプロイ前にターゲットリポジトリの既存ファイルのエンコーディングを確認すべき
