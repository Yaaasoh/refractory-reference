# Refractory Materials Technical Glossary

耐火物・製鉄・建設分野の技術用語集

---

## 概要

本リポジトリは、耐火物（refractory materials）、製鉄（steel industry）、建設施工（construction）、レオロジー・シミュレーション（rheology and simulation）に関する技術用語集を提供します。

---

## 使い方

### 用語の検索

1. **カテゴリ別検索**: 下記5ファイルから該当分野を選択
2. **全文検索**: Grep、IDE検索機能を使用
3. **GitHub検索**: リポジトリ内検索機能を使用

### 用語定義の形式

各用語集ファイルはMarkdownテーブル形式で記載されています。

詳細は `glossary/README.md` を参照してください。

---

## ディレクトリ構成

```
refractory-reference/
├── README.md                    （本ファイル）
├── glossary/                    （用語集本体）
│   ├── README.md
│   ├── 02-materials.md          （材料・物性）
│   ├── 03-equipment.md          （設備・機器）
│   ├── 04-construction.md       （施工・打設）
│   ├── 05-steel-industry.md     （製鉄プロセス）
│   └── 06-rheology-simulation.md（レオロジー・シミュレーション）
└── validation/                  （品質検証システム）
    ├── VALIDATION_WORKFLOW.md   （検証ワークフロー）
    ├── REFERENCES.md            （参照規格一覧）
    ├── validate_glossary.sh     （検証スクリプト）
    └── patterns/                （検出パターン）
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

詳細は各ファイル、または `glossary/README.md` を参照してください。

---

## 品質検証システム（validation/）

### 概要

用語集の品質を維持するため、自動検証システムを提供しています。

**検証項目**:
- データ品質確認
  - マークダウン構造の整合性
  - テーブル形式の統一
  - 文字化けチェック
  - 用語定義の品質
- パターン検出
  - 不適切なコンテンツの検出
  - 品質基準への準拠確認

### 使用方法

```bash
# 用語集ファイルの検証
cd refractory-reference
./validation/validate_glossary.sh glossary/

# 出力例
[PASS] データ品質: 問題なし
[PASS] テーブル構造: 問題なし
[PASS] 文字化け: 0件検出

# 終了コード
# 0 = 検証合格
# 1 = 要確認
```

### 詳細情報

- **VALIDATION_WORKFLOW.md**: 検証プロセスの詳細
- **REFERENCES.md**: 参照規格一覧
- **patterns/**: 検出パターン定義

---

**最終更新**: 2025-12-20
