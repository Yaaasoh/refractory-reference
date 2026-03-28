# 文書品質ルール

**対策対象**: 文書構造の崩壊、自己申告による検証の形骸化
**優先度**: Medium
**適用範囲**: すべてのパッケージ（technical, prompt-creation）
**出典**: prescribed-format-framework 20件のインシデント分析、JAC案件レジュメ準備の教訓

## 概要

このルールは、Claude Codeで作成する文書の品質を機械的に担保する原則を定義します。

**対象となる文書**: 作業報告書、調査報告書、規定フォーマット文書（職務経歴書・提案書等）

## やってはいけないこと

### 1. 自己申告による検証

**絶対禁止**:
- 文書を生成した後「問題ありません」と自己判断する
- 構造チェックをスクリプトで実行せず「目視確認しました」と報告する
- スキーマに定義された制約（文字数・項目数）を確認せずに完了報告する

**具体例**:
```markdown
# ❌ 悪い例：自己検証
「作業報告書を作成しました。構造を確認し、問題ありません。」
→ 実際: 必須セクション「成果物」が欠落

# ✅ 正しい例：機械検証
$ ./scripts/validate-document.sh schemas/work-report.schema.yaml report.md
=== 構造検証: report.md ===
  エラー: 1件 — 必須セクション「成果物」が見つかりません
  結果: FAIL
→ 「成果物」セクションを追加してから再検証
```

### 2. スキーマなしの構造管理

**禁止**:
- 繰り返し作成する文書タイプにスキーマを定義しない
- 暗黙のルール（「概要は200文字以内」等）を口頭伝達のみで運用する
- セクション構成を毎回変える

### 3. 生成者による自己検証

**禁止**:
- 文書を生成したエージェント（メインプロセス）が自分で検証して「OK」と判断する

## やるべきこと

### 原則1: 機械検証 > 自己申告

**優先順位**:
1. スクリプトによる自動検証（最も信頼性が高い）
2. サブエージェント（Taskツール）による検証（生成者とは別のコンテキスト）
3. 人間による確認（最終判断）

**LLMの「問題ありません」は検証にならない**。

### 原則2: スキーマ駆動

**繰り返し作成する文書にはスキーマYAMLを定義する**:

```yaml
# 最小スキーマの例
metadata:
  format_name: "作業報告書"
  version: "1.0.0"

sections:
  - id: overview
    title: "概要"
    level: 2
    required: true
    order: 1
    constraints:
      min_chars: 50
      max_chars: 500

  - id: deliverables
    title: "成果物"
    level: 2
    required: true
    order: 2

prohibited_sections:
  - "Draft"
  - "TODO"
```

**スキーマの配置先**: `shared/docs/templates/schemas/`

### 原則3: 生成者と検証者の分離

**文書を生成したエージェントが自己検証しない**:

```markdown
# ✅ 正しいワークフロー
1. メインエージェント: 文書を生成
2. PostToolUseフック: 構造検証スクリプトを自動実行（L1）
3. サブエージェント（Taskツール）: 内容検証を実行（L2-L3）
```

### 原則4: constraints（制約）の明示

**暗黙の制約を排除し、スキーマに明記する**:

| 制約タイプ | 用途 | 例 |
|-----------|------|-----|
| `min_chars` | 最小文字数 | 概要: 50文字以上 |
| `max_chars` | 最大文字数 | 概要: 500文字以内 |
| `min_items` | 最小項目数 | 実施内容: 1件以上 |
| `max_items` | 最大項目数 | 次のステップ: 5件以内 |

### 原則5: 段階的検証（L1→L2→L3）

文書の重要度に応じて検証レベルを選択する:

| レベル | 検証内容 | 実行方法 | コスト |
|:------:|---------|---------|:------:|
| L1 構造 | セクション存在・順序・制約 | スクリプト自動実行 | 低 |
| L2 内容 | データ一致・固有名詞・禁止パターン | 手動またはサブエージェント | 中 |
| L3 セマンティック | 忠実度・捏造検出・欠落検出 | サブエージェント | 高 |

**選択基準**:
- 作業報告書（内部文書）: L1のみで十分
- 調査報告書（成果物）: L1 + L2
- 規定フォーマット文書（外部提出）: L1 + L2 + L3

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 文書品質の基本原則提示

### Layer 2: Skills
- **効果**: 中（文書生成タスクで起動）
- **スキル**: `format-writer`（prescribed-format-framework）
- **機能**: スキーマ読み込み→生成→L1検証→L2検証の統合ワークフロー

### Layer 3: Hooks
- **効果**: 強（文書書き込み時に自動検証）
- **フック**: `auto-validate.sh`（PostToolUse: Write/Edit）
- **機能**: スキーマ対象ファイルへの書き込みを検出し、構造検証を自動実行

## 関連ドキュメント

### スキーマ・検証ツール
- `shared/docs/templates/schemas/` - スキーマYAML配置先
- `shared/scripts/validate-document.sh` - 汎用構造検証スクリプト

### 参照実装
- `work/prescribed-format-framework/` - 規定フォーマット文書フレームワーク（JAC実証）
- `work/prescribed-format-framework/scripts/validate-structure.sh` - JAC用構造検証（フル版）
- `work/prescribed-format-framework/scripts/validate-content.sh` - JAC用内容検証（L2）

### 共有ルール
- `shared/rules/evidence-based-thinking.md` - 証拠ベース思考
- `shared/rules/anti-tampering-rules.md` - 改ざん防止

---

**最終更新**: 2026-02-19
**バージョン**: 1.0
**ステータス**: 新規作成
**適用**: すべてのパッケージ
