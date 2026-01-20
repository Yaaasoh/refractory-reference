# Refractory Materials Technical Glossary

耐火物・製鉄・建設分野の技術用語集

---

## ウェブサイト

https://yaaasoh.github.io/refractory-reference/

---

## 概要

本リポジトリは、耐火物（refractory materials）、製鉄（steel industry）、建設施工（construction）、レオロジー・シミュレーション（rheology and simulation）に関する技術用語集を提供します。

---

## 使い方

### 用語の検索

1. **ウェブサイト**: 上記URLで全文検索が可能
2. **カテゴリ別検索**: 下記5ファイルから該当分野を選択
3. **GitHub検索**: リポジトリ内検索機能を使用

### 用語定義の形式

各用語集ファイルはMarkdownテーブル形式で記載されています。

詳細は `glossary/README.md` を参照してください。

---

## ディレクトリ構成

```
refractory-reference/
├── README.md                    （本ファイル）
├── mkdocs.yml                   （MkDocs設定）
├── docs/                        （MkDocsソース）
│   ├── index.md
│   └── glossary/
├── glossary/                    （用語集本体）
│   ├── README.md
│   ├── 02-materials.md          （材料・物性）
│   ├── 03-equipment.md          （設備・機器）
│   ├── 04-construction.md       （施工・打設）
│   ├── 05-steel-industry.md     （製鉄プロセス）
│   └── 06-rheology-simulation.md（レオロジー・シミュレーション）
├── validation/                  （品質検証）
└── .github/workflows/           （GitHub Actions）
```

---

## 用語集ファイル（glossary/）

| ファイル | 内容 | セクション数 |
|---------|------|---------------|
| **02-materials.md** | 材料・物性（耐火物種類、物性値、規格） | 12 |
| **03-equipment.md** | 設備・機器（ミキサー、コンベア、圧送機） | 7 |
| **04-construction.md** | 施工・打設（施工方法、養生、検査） | 15 |
| **05-steel-industry.md** | 製鉄プロセス（高炉、転炉、用途） | 10 |
| **06-rheology-simulation.md** | レオロジー・シミュレーション（流動解析、CFD） | 14 |

**合計**: 58セクション（約360用語エントリ）

---

## 品質検証

`validation/` には用語集の品質を維持するための検証スクリプトが含まれています。

---

**最終更新**: 2026-01-20
