# Plan Mode 計画品質ルール

**対策対象**: 計画フェーズの調査不足、願望リスト型計画
**優先度**: High
**適用範囲**: すべてのパッケージ
**出典**: Claude Code公式ドキュメント（common-workflows, best-practices）、obra/superpowers

## 概要

Plan Modeは「Explore → Plan → Implement → Commit」の前半2フェーズを担う。
計画承認後に新たな調査を始めるのはアンチパターン。

**Plan Modeで使えるツール**:

| 許可 | 禁止 |
|------|------|
| Read, Grep, Glob | Edit, Write, NotebookEdit |
| Bash（読み取り系） | |
| WebSearch, WebFetch | |
| Agent（read-onlyサブエージェント） | |
| AskUserQuestion | |

## やってはいけないこと

### 1. 調査なしの計画作成

**絶対禁止**:
- Read/Grep/Globを1回も使わずに計画を作成する
- 既存コードを読まずに「〜を参考」と書く
- ファイル構成を確認せずにファイルパスを提示する

### 2. 願望リスト型の計画

**禁止**:
- 根拠のない「〜を参考」「〜に従う」
- 「確認済み」と書いていないファイル参照
- 変更内容の具体性がない箇条書き

**具体例**:
```markdown
# 悪い計画（願望リスト）
- python-docx 1.2.0 使用
- scripts/extract.py のスタイル参考
- temp/*.json の出力フォーマット参考

問題点:
- 「参考」と書いているが実際に読んでいない
- 何を参考にするのか具体性がない
- 設計判断の根拠がない
```

### 3. 計画承認後の再調査

**禁止**:
- Normal Modeに切り替えてから既存コードを読み始める
- 計画にないファイルをImplementフェーズで調査する
- 「計画にはなかったが〜が必要だった」を繰り返す

**対処**: 計画にない問題を発見した場合、再度Plan Modeに戻る

### 4. 計画承認と実装許可の混同

**計画承認 ≠ 実装許可**

**禁止**:
- 検討フェーズ中に実装修正を無許可で開始する
- 計画が承認されたことを理由に、フェーズ境界を無視して作業を進める
- 緊急性を自己判断して計画外の実装を行う

**正しい手順**:
1. Plan Modeで計画を提示し承認を得る
2. ユーザーが「実装してください」と明示するまで待つ
3. 緊急の問題を発見した場合、まず報告し判断を仰ぐ

## やるべきこと

### 1. Plan Mode使用判断基準

| 使うべき | スキップすべき |
|---------|-------------|
| 複数ファイル（3+）への変更 | 1-2ファイルの明確な修正 |
| コードベース全体の理解が必要 | タイポ修正、ログ追加 |
| 実装方針が不確実 | 1文で説明できる修正 |
| 3ステップ以上の作業 | 実験・プロトタイプ |

### 2. Plan Mode内の正しい作業順序

**フェーズ1: 探索（Explore）** — Plan Mode内
1. Grep/Globで関連ファイルを特定する
2. Readで既存コード・データを実際に読む
3. 既存パターン・規約を把握する
4. AskUserQuestionで曖昧な要件を明確化する

**フェーズ2: 計画（Plan）** — Plan Mode内
1. 読んだ事実に基づいて設計する
2. 「何を・どのファイルで・なぜ」を具体的に提示する
3. ユーザーの承認を得る

**フェーズ3: 実装（Implement）** — Normal Mode
1. 計画に従って実装する（新たな調査は原則不要）
2. テスト・検証する
3. 計画にない問題を発見 → 再度Plan Modeに戻る

### 3. 計画の最小要件

**「ファイルパス + 変更内容 + 根拠（読んだ事実）」**

```markdown
# 良い計画（調査に基づく設計）
- 既存スクリプト extract.py を確認済み:
  - argparse使用、logger設定パターン（L12-25）
  - 出力: json.dump(data, f, ensure_ascii=False, indent=2)
  - エラー処理: try/except + sys.exit(1)
- temp/sample_extraction.json を確認済み:
  - comments: 25件、insertions: 142件
  - author形式: "山田 太郎"（姓名スペース区切り）
- 設計判断: XMLパースはoxml経由でlxml.etreeを使用
  （理由: python-docxはtracked changesのAPIを提供していないため）
```

特徴:
- 「確認済み」— 実際に読んだことが明示されている
- 具体的な行番号、件数、フォーマットが記載されている
- 設計判断に「理由」が添えられている

### 4. 詳細度3段階（タスク複雑度に応じて）

| レベル | 対象 | 計画の内容 |
|:------:|------|-----------|
| **Simple** | 1-2ファイル、明確な修正 | ファイルパス + 変更概要 |
| **Medium** | 3-5ファイル、中程度の変更 | + 既存パターン確認結果 + 設計判断の根拠 |
| **Complex** | 6+ファイル、アーキテクチャ変更 | + 影響範囲分析 + テスト戦略 + リスク項目 |

## evidence-based-thinking.md との関係

本ルールは「Read First, Code Later」のPlan Mode版。
証拠ベース思考の原則（推測ではなく実際のコードを読む）をPlan Modeワークフローに適用したもの。

Plan Mode使用時は本ルールに従い、計画フェーズでの調査義務を遵守する。

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本文書）
- **効果**: 中（Plan Mode中のコンテキストに含まれる）
- **役割**: 計画品質基準の提示

### Layer 2: Hooks
- **効果**: 中（大規模作業検出→Plan Mode推奨）
- **フック**: `plan_mode_reminder.sh`（UserPromptSubmit）
- **機能**: 大規模作業キーワード検出時にPlan Mode利用をリマインダー表示

## 関連ドキュメント

- `shared/rules/evidence-based-thinking.md` - 証拠ベース思考（Read First, Code Later）
- `shared/rules/task-integrity.md` - タスク完全性

## 参考リンク

- [Claude Code Common Workflows](https://code.claude.com/docs/en/common-workflows): 「Use Plan Mode for safe code analysis」
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices): 「Explore → Plan → Implement → Commit」
- [obra/superpowers](https://github.com/obra/superpowers): 「Do your research first」

---

**最終更新**: 2026-03-17
**バージョン**: 1.1
**ステータス**: H2教訓追加
**適用**: すべてのパッケージ
