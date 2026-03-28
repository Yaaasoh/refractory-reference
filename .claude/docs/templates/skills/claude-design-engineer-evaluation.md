# claude-design-engineer 導入評価レポート

**作成日**: 2026-01-18
**評価対象**: [Dammyjay93/claude-design-engineer](https://github.com/Dammyjay93/claude-design-engineer)

---

## 1. エグゼクティブサマリー

| 項目 | 評価 |
|------|------|
| **推奨度** | ⭐⭐⭐⭐☆ (4/5) |
| **導入労力** | 低（プラグインインストールのみ） |
| **価値** | セッション間のデザイン一貫性維持に高い効果 |
| **リスク** | コミュニティ製のため長期サポート不確実 |

**結論**: **導入推奨**（特に継続的なWebプロジェクトで有効）

---

## 2. 機能概要

### 2.1 3つの核心機能

| 機能 | 説明 | 価値 |
|------|------|------|
| **Craft（構築）** | プロジェクト文脈から設計方向を自動推論 | 初期設定の自動化 |
| **Memory（記憶）** | `.design-engineer/system.md`に決定事項を保存 | セッション間の一貫性 |
| **Enforcement（強制）** | 違反を検出・自動修正 | 品質維持の自動化 |

### 2.2 専用コマンド

| コマンド | 機能 |
|---------|------|
| `/design-engineer:init` | 自動モード選択・初期設定 |
| `/design-engineer:status` | 現在のデザインシステム表示 |
| `/design-engineer:audit <path>` | コード検証・違反検出 |
| `/design-engineer:extract` | 既存コードからパターン抽出 |

### 2.3 Memory機能の詳細

`.design-engineer/system.md`に保存される情報:
- グリッドシステム（4px, 8px等）
- カラーパレット
- タイポグラフィスケール
- スペーシング規則
- コンポーネントパターン

---

## 3. 評価

### 3.1 メリット

| メリット | 詳細 |
|---------|------|
| **セッション間一貫性** | Memory機能により、複数セッションで同一デザインシステムを維持 |
| **自動違反検出** | "17pxは4pxグリッドに非準拠"等の警告 |
| **既存プロジェクト対応** | `extract`コマンドで既存コードからパターン抽出可能 |
| **導入容易** | `/plugin marketplace add`のみ |
| **非侵襲的** | `.design-engineer/`ディレクトリに閉じている |

### 3.2 デメリット・リスク

| デメリット | 詳細 | 緩和策 |
|-----------|------|--------|
| **コミュニティ製** | 長期サポート不確実 | SKILL.mdをローカルにバックアップ |
| **依存関係** | プラグインシステムへの依存 | 必要な指示をCLAUDE.mdに転記 |
| **学習コスト** | 専用コマンドの習得必要 | ドキュメント整備で対応 |
| **競合可能性** | 他のデザインSkillとの競合 | 使用Skillを明確に選択 |

### 3.3 frontend-design Skillとの比較

| 観点 | frontend-design | claude-design-engineer |
|------|-----------------|------------------------|
| **提供元** | Anthropic公式 | コミュニティ |
| **焦点** | 美学的品質向上 | システム一貫性維持 |
| **状態管理** | なし（ステートレス） | あり（Memory機能） |
| **違反検出** | なし | あり（Enforcement） |
| **併用** | 可能 | 可能 |

**推奨**: **両方を併用**（frontend-designで美学、claude-design-engineerで一貫性）

---

## 4. 導入手順

### 4.1 インストール

```bash
/plugin marketplace add Dammyjay93/claude-design-engineer
```

### 4.2 初期設定

```bash
/design-engineer:init
```

対話形式で以下を設定:
- グリッドシステム
- カラーパレット
- タイポグラフィ

### 4.3 既存プロジェクトへの適用

```bash
/design-engineer:extract
```

既存コードからパターンを自動抽出し、`.design-engineer/system.md`を生成。

### 4.4 検証

```bash
/design-engineer:audit src/components/
```

---

## 5. 使用シナリオ

### 5.1 推奨シナリオ

| シナリオ | 理由 |
|---------|------|
| 継続的なWebプロジェクト | Memory機能で一貫性維持 |
| チーム開発 | `.design-engineer/`をGit管理で共有 |
| デザインシステム構築 | パターン抽出・強制が有効 |
| リファクタリング | audit機能で違反を一括検出 |

### 5.2 不向きなシナリオ

| シナリオ | 理由 |
|---------|------|
| 単発のプロトタイプ | Memory機能の価値が低い |
| デザイン自由度重視 | Enforcement機能が制約になる |
| 非Web開発 | Web/CSSに特化 |

---

## 6. prompt-patternsへの統合方針

### 6.1 配置先

```
shared/docs/templates/skills/
├── frontend-design-skill-guide.md       # E0: 公式Skill
└── claude-design-engineer-evaluation.md # E0b: 本文書
```

### 6.2 デプロイ対象リポジトリ

| リポジトリ | 推奨度 | 理由 |
|-----------|:------:|------|
| dify-apps | 高 | Web UI開発あり |
| tech-articles | 中 | 静的サイト生成 |
| その他技術系 | 低 | フロントエンド部分のみ |

### 6.3 CLAUDE.mdへの記載

導入するリポジトリのCLAUDE.mdに以下を追加:

```markdown
## Design System Tools

### claude-design-engineer
- `/design-engineer:init` - デザインシステム初期化
- `/design-engineer:status` - 現在の設定確認
- `/design-engineer:audit <path>` - コード検証
- デザイン決定は `.design-engineer/system.md` に自動保存
```

---

## 7. 代替案

claude-design-engineerを導入しない場合の代替:

### 7.1 CLAUDE.mdでの手動管理

```markdown
## Design System

### Grid
- Base unit: 4px
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64

### Colors
- Primary: #3B82F6
- Secondary: #10B981
- Background: #0F172A
- Text: #F8FAFC

### Typography
- Heading: Space Grotesk
- Body: Inter
- Code: JetBrains Mono
```

**欠点**: 違反検出・自動修正がない

### 7.2 カスタムSkill作成（E5）

独自のdesign-system-enforcer Skillを作成。

**欠点**: 開発工数がかかる

---

## 8. 結論と推奨

### 8.1 導入判断

| 条件 | 判断 |
|------|------|
| 継続的なWebプロジェクトがある | **導入推奨** |
| デザイン一貫性が課題 | **導入推奨** |
| 単発プロジェクトのみ | 導入不要 |
| 非Web開発のみ | 導入不要 |

### 8.2 導入する場合の推奨構成

```
1. frontend-design Skill（公式）: 美学的品質向上
   +
2. claude-design-engineer: システム一貫性維持
```

両者は補完関係にあり、併用が最も効果的。

---

## 9. 参照

| リソース | URL |
|---------|-----|
| GitHub | [Dammyjay93/claude-design-engineer](https://github.com/Dammyjay93/claude-design-engineer) |
| 関連調査 | `work/research/claude-code-design-capabilities/phase5_skills_deep_dive.md` |

---

**ステータス**: 評価完了・導入推奨
