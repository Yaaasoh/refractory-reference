# frontend-design Skill 導入ガイド

**作成日**: 2026-01-18（更新: 2026-03-17）
**対象**: Claude Code CLI
**現行Skill**: `shared/skills/frontend-design/SKILL.md` v2.0.0 + `reference/` 6ファイル

---

## 1. 概要

Anthropic公式の`frontend-design` Skillを導入し、「AI slop」美学を回避したプロダクショングレードのフロントエンドを生成する。

### 期待効果

- 独特で美しいタイポグラフィ
- 一貫した色彩・テーマ設計
- 高インパクトなモーション・アニメーション
- 非対称・オーバーラップを活用した空間構成

---

## 2. インストール手順

### 2.1 Anthropic公式Skillsリポジトリの追加

```bash
/plugin marketplace add anthropics/skills
```

### 2.2 example-skillsパッケージのインストール

```bash
/plugin install example-skills@anthropic-agent-skills
```

これにより以下のSkillsが利用可能になる:
- `frontend-design` - フロントエンドデザイン
- `theme-factory` - プロフェッショナルテーマ適用
- `canvas-design` - PNG/PDFビジュアルアート
- `algorithmic-art` - p5.jsジェネレーティブアート
- `slack-gif-creator` - Slack最適化GIF

### 2.3 インストール確認

```bash
/plugin list
```

`frontend-design`が一覧に表示されることを確認。

---

## 3. 使用方法

### 3.1 自動起動

フロントエンド関連のタスク（React、Vue、CSS、UI等）で自動的にSkillが起動する。

### 3.2 明示的な起動

```
/frontend-design
```

または、プロンプトで明示:
```
Use the frontend-design skill to create a dashboard UI.
```

---

## 4. Skillの核心コンセプト

### 4.1 Design Thinking（コーディング前の必須思考）

```markdown
Before coding, understand the context and commit to a **BOLD aesthetic direction**:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme aesthetic direction
  (brutally minimal, maximalist chaos, retro-futuristic,
   organic/natural, luxury/refined, playful/toy-like, etc.)
- **Constraints**: Technical requirements (framework, performance, accessibility)
- **Differentiation**: What makes this UNFORGETTABLE?
```

### 4.2 4つの重点領域

| 領域 | ガイドライン |
|------|-------------|
| **Typography** | 独特で美しいフォント。Inter, Roboto, Arial回避 |
| **Color & Theme** | 一貫した美学、CSS変数、支配色+シャープなアクセント |
| **Motion** | 高インパクトな瞬間（ページロード、スクロール）に集中 |
| **Spatial Composition** | 非対称、オーバーラップ、グリッドブレイク |

### 4.3 回避すべきパターン

- 使い古されたフォント（Inter, Roboto, Arial）
- 白背景に紫グラデーション
- 予測可能なレイアウトとコンポーネントパターン

---

## 5. 推奨フォントリスト

### 5.1 コード・技術系

| フォント | 特徴 |
|---------|------|
| JetBrains Mono | モダン、リガチャ対応 |
| Fira Code | リガチャ対応、広く利用 |
| Space Grotesk | 幾何学的、技術的 |

### 5.2 エディトリアル・コンテンツ系

| フォント | 特徴 |
|---------|------|
| Playfair Display | クラシック、エレガント |
| Crimson Pro | 可読性高い本文向け |
| Fraunces | 個性的なセリフ |

### 5.3 スタートアップ・モダン系

| フォント | 特徴 |
|---------|------|
| Clash Display | 大胆、インパクト |
| Satoshi | クリーン、モダン |
| Cabinet Grotesk | 幾何学的、親しみやすい |

---

## 6. プロンプト例

### 6.1 基本的な使用

```
Create a landing page for a fintech startup.
Target: Young professionals
Aesthetic: Luxury/refined with bold typography
```

### 6.2 詳細な指定

```
Design a dashboard UI with the following requirements:

Purpose: Real-time data monitoring for DevOps teams
Tone: Brutally minimal, dark mode, high contrast
Constraints: React + Tailwind CSS, must be accessible (WCAG AA)
Differentiation: Unique data visualization with subtle animations

Typography: Use Space Grotesk for headings, IBM Plex Mono for data
Color: Deep navy (#0a1628) base, electric cyan (#00d4ff) accents
Motion: Staggered reveal on page load, smooth transitions on hover
```

---

## 7. CLAUDE.mdへの統合

以下をプロジェクトのCLAUDE.mdに追加することで、Skill未導入環境でも同様の効果を得られる:

```markdown
## Frontend Design Standards

<frontend_aesthetics>
You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight. Focus on:

Typography: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.

Color & Theme: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.

Motion: Use animations for effects and micro-interactions. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions.

Backgrounds: Create atmosphere and depth rather than defaulting to solid colors. Layer CSS gradients, use geometric patterns.

Avoid:
- Overused fonts (Inter, Roboto, Arial)
- Purple gradients on white backgrounds
- Predictable layouts and component patterns
</frontend_aesthetics>
```

---

## 8. 効果測定（参考）

Anthropicの実験結果:
- 改善版Skill: **75%の勝率**（オリジナル比較）
- 小規模モデル（Haiku）でより大きな効果
- 明確な指示はより制限されたモデルに有益

---

## 9. 関連リソース

| リソース | URL |
|---------|-----|
| 公式リポジトリ | [anthropics/skills](https://github.com/anthropics/skills) |
| 公式ブログ | [Improving frontend design through Skills](https://claude.com/blog/improving-frontend-design-through-skills) |
| プロンプティングガイド | [Prompting for frontend aesthetics](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics) |

---

## 10. トラブルシューティング

### Skillが起動しない場合

1. `/plugin list`でインストール確認
2. `/plugin reinstall example-skills@anthropic-agent-skills`で再インストール
3. Claude Codeを再起動

### 効果が感じられない場合

1. プロンプトで美学的方向性を明示的に指定
2. 「Purpose」「Tone」「Differentiation」を必ず含める
3. 具体的なフォント・色を指定

---

## 11. v2.0.0 更新情報（2026-03-17）

prompt-patternsリポジトリでは自前のSKILL.md v2.0.0をdeploy.shで全リポジトリに展開済み。
公式Plugin経由のインストール（§2）は不要。

**v2.0.0の主要変更**:
- Tone: 8→11種（Editorial/magazine, Brutalist/raw, Art deco/geometric追加）
- OKLCH色空間、Tinted Neutrals、60-30-10ルール
- 4ptベーススペーシング（CSS変数テンプレート）
- 100/300/500ルール（アニメーション持続時間）、cubic-bezier具体値
- reference/ 6ファイル新規: interaction-design, responsive-design, accessibility, ux-writing, performance, dark-mode

**外部ツール（参考）**: Impeccable/Vercel web-design-guidelinesの知識は v2.0.0に吸収済み。直接導入は不要。

---

**ステータス**: v2.0.0展開済み（全19リポジトリ）
