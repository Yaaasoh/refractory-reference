# CLAUDE.md - refractory-reference

**更新日**: 2026-01-03

---

## 絶対禁止事項

以下のコマンドは**いかなる理由があっても実行禁止**:

- `rm -rf` / `rm -r`
- `git clean -fd` / `git clean -f`
- `git reset --hard`
- `find . -delete`

---

## プロジェクト概要

**耐火物・製鉄・建設分野の技術用語集**

- **耐火物 (Refractory Materials)**: 材料・物性用語
- **製鉄 (Steel Industry)**: 製鉄プロセス用語
- **建設 (Construction)**: 施工・打設用語
- **レオロジー・シミュレーション**: 流動特性・解析用語

---

## ディレクトリ構成

```
refractory-reference/
├── glossary/                     # 用語集本体
│   ├── 02-materials.md           # 材料・物性
│   ├── 03-equipment.md           # 設備・機器
│   ├── 04-construction.md        # 施工・打設
│   ├── 05-steel-industry.md      # 製鉄プロセス
│   └── 06-rheology-simulation.md # レオロジー・シミュレーション
├── validation/                   # 品質検証システム
│   ├── validate_glossary.sh      # 検証スクリプト
│   └── patterns/                 # 検出パターン
├── docs/                         # MkDocs文書
└── site/                         # 生成サイト
```

---

## 用語定義形式

各用語集ファイルはMarkdownテーブル形式:

| 英語 | 日本語 | 略語 | 分類 | 説明 |
|------|--------|------|------|------|

---

## 検証コマンド

```bash
# 用語集検証
./validation/validate_glossary.sh

# MkDocsビルド
mkdocs build

# ローカルサーバー起動
mkdocs serve
```

---

## 関連リポジトリ

- **tech-research-portfolio**: 材料力学・シミュレーション研究
- **case-htm**: 耐火物関連プロジェクト

---

## 学習メモ

- 2026-01-03: CLAUDE.mdをテンプレートから記入（44行→約75行）
