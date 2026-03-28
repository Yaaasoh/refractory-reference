# frontend-design Skill

**Version**: 2.0.0
**Author**: prompt-patterns
**Based on**: Anthropic official frontend-design Skill + Impeccable (8.5k★) + Vercel web-design-guidelines

**変更履歴**:
- v2.0.0 (2026-03-17): Tone 11種、OKLCH色空間、4ptスペーシング、イージング具体値、reference/6ファイル追加
- v1.0.0 (2026-03-15): 初版（公式Skillベース）

---

## Description

フロントエンド開発時に「AI slop」美学を回避し、創造的で独特なUIを生成するためのSkill。
React、Vue、Tailwind CSS等のフロントエンド技術で使用。

**トリガー**:
- フロントエンドコンポーネント作成
- UI/UXデザイン実装
- スタイリング作業
- ランディングページ・ダッシュボード作成

---

## Design Thinking

コーディング前に、以下を明確にすること:

### 1. Purpose（目的）
- このインターフェースが解決する問題は何か？
- 誰が使うか？

### 2. Tone（トーン）
以下から**大胆な**美学的方向性を1つ選択:

| トーン | 特徴 |
|-------|------|
| Brutally minimal | 極限のミニマル、余白重視 |
| Maximalist chaos | 最大主義、要素の重なり、カオス |
| Retro-futuristic | レトロフューチャー、80s-90sテック |
| Organic/natural | オーガニック、曲線、自然な色 |
| Luxury/refined | ラグジュアリー、洗練、上品 |
| Playful/toy-like | 遊び心、カラフル、親しみやすい |
| Dark & moody | ダーク、ムーディー、高コントラスト |
| Artisanal/crafted | 職人的、手作り感、テクスチャ |
| Editorial/magazine | エディトリアル、大胆なタイポグラフィ、余白 |
| Brutalist/raw | ブルータリスト、生々しい、デフォルトHTML風 |
| Art deco/geometric | アールデコ、幾何学パターン、金属色 |

### 3. Constraints（制約）
- フレームワーク（React/Vue/etc）
- パフォーマンス要件
- アクセシビリティ要件（WCAG AA等）

### 4. Differentiation（差別化）
- 何がこのUIを**忘れられないもの**にするか？

---

## Typography

### 推奨フォント

| カテゴリ | フォント | 用途 |
|---------|---------|------|
| **Code/Tech** | JetBrains Mono, Fira Code, Space Grotesk | 技術系、開発ツール |
| **Editorial** | Playfair Display, Crimson Pro, Fraunces | コンテンツ、記事 |
| **Modern** | Clash Display, Satoshi, Cabinet Grotesk | SaaS、スタートアップ |
| **Geometric** | Outfit, Manrope, Plus Jakarta Sans | クリーン、汎用 |

### 回避すべきフォント

| 回避 | 理由 | 代替 |
|------|------|------|
| Inter | 過度に使用されている | Instrument Sans, Outfit |
| Roboto | Googleデフォルト感 | Onest, Figtree |
| Arial | システムフォント感 | Geist Sans |
| Open Sans | 無個性 | Plus Jakarta Sans |
| Lato | 過剰使用 | Manrope |
| Montserrat | AI生成感 | Satoshi |

### フォント原則
- **フォントペアリングは1組まで**: 多くの場合、1ファミリー（weight違い）で十分
- **Variable Fontsを優先**: ファイルサイズ削減 + 表現力向上
- `font-display: swap` を必ず指定

---

## Color & Theme

### 原則

1. **支配色を決める**: 1つの主要色を選び、大胆に使用
2. **60-30-10ルール**: 背景60%、補助30%、アクセント10%
3. **OKLCH色空間を推奨**: HSLの知覚的非均一性を解決
4. **Tinted Neutrals**: 純粋グレーを避け、ブランド色で微量着色（chroma 0.005-0.01）
5. **CSS変数で一貫性**: すべての色はCSS変数で定義
6. **コントラスト比**: 本文4.5:1、大テキスト/UIコンポーネント3:1（WCAG AA）

### CSS変数テンプレート

```css
:root {
  /* OKLCH Primitive tokens */
  --color-primary: oklch(0.55 0.25 250);
  --color-primary-hover: oklch(0.45 0.25 250);

  /* Tinted Neutrals (blue-tinted) */
  --color-surface: oklch(0.15 0.01 250);
  --color-surface-raised: oklch(0.20 0.01 250);

  /* Semantic tokens */
  --color-background: oklch(0.10 0.005 250);
  --color-text: oklch(0.95 0.005 250);
  --color-text-muted: oklch(0.65 0.01 250);
}
```

### 回避すべきパターン

- 白背景に紫グラデーション
- 均等に分散した臆病なパレット
- 単色のフラットな背景
- 純粋グレー（`#808080`等）のneutrals

**ダークモード詳細**: → `reference/dark-mode.md`

---

## Motion

### 原則

1. **高インパクトな瞬間に集中**: ページロード、重要なインタラクション
2. **Staggered reveals**: `animation-delay`で段階的表示
3. **transform優先**: `width/height`より`transform/opacity`
4. **アクセシビリティ**: `prefers-reduced-motion`を尊重

### 持続時間ガイド（100/300/500ルール）

| 用途 | 持続時間 | 例 |
|------|---------|-----|
| マイクロフィードバック | 100-150ms | ボタンpress、トグル |
| 標準トランジション | 200-350ms | パネル開閉、フェード |
| 大きなレイアウト変化 | 400-500ms | ページ遷移、モーダル |

**退出アニメーション**: 入場の75%の持続時間

### イージングカーブ

| タイプ | cubic-bezier | 用途 |
|-------|-------------|------|
| ease-out | `(0.16, 1, 0.3, 1)` | 入場（画面外→画面内） |
| ease-in | `(0.7, 0, 0.84, 0)` | 退場（画面内→画面外） |
| ease-in-out | `(0.45, 0, 0.55, 1)` | 状態変化 |

### Framer Motion パターン

```tsx
import { motion, useReducedMotion } from "framer-motion"

function Card({ children, index }) {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      initial={shouldReduceMotion ? {} : { opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{
        duration: 0.3,
        delay: index * 0.1,
        ease: [0.16, 1, 0.3, 1]
      }}
    >
      {children}
    </motion.div>
  )
}
```

### 回避すべきパターン

- 散発的なマイクロインタラクション
- 500ms以上の長いアニメーション
- `width/height`アニメーション（パフォーマンス問題）
- bounce/elasticイージング（dated感）

---

## Spatial Composition

### 4ptベースユニット

すべてのスペーシングは4の倍数:

```css
:root {
  --space-xs: 4px;   /* 密着 */
  --space-sm: 8px;   /* 要素内 */
  --space-md: 16px;  /* 要素間 */
  --space-lg: 24px;  /* セクション内 */
  --space-xl: 32px;  /* セクション間 */
  --space-2xl: 48px; /* 大きな区切り */
  --space-3xl: 64px; /* ページレベル */
  --space-4xl: 96px; /* ヒーロー */
}
```

- CSS `gap` を推奨（margin collapseを回避）
- **Squint Test**: ぼかして視ても階層が見えるか確認

### 推奨パターン

- **非対称レイアウト**: 予測可能なグリッドを破る
- **オーバーラップ**: 要素の重なりで深みを出す
- **ネガティブスペース**: 意図的な余白
- **グリッドブレイク**: 一部要素をグリッドから外す

### 回避すべきパターン

- すべて整列した予測可能なグリッド
- 均等な余白
- 「安全な」レイアウト選択

---

## Backgrounds

### 推奨パターン

- **レイヤードグラデーション**: 複数のグラデーションを重ねる
- **幾何学パターン**: SVGまたはCSSパターン
- **メッシュグラデーション**: 複雑な色の流れ
- **ノイズテクスチャ**: 微細なグレインで質感を追加

### CSS例

```css
.hero-background {
  background:
    linear-gradient(135deg, oklch(0.55 0.15 250 / 0.1) 0%, transparent 50%),
    linear-gradient(225deg, oklch(0.55 0.15 300 / 0.1) 0%, transparent 50%),
    var(--color-background);
}
```

---

## Checklist

コンポーネント作成時の確認:

**Design Thinking**:
- [ ] 4要素（Purpose/Tone/Constraints/Differentiation）を検討したか？
- [ ] 「安全な」選択を避け、大胆な決断をしているか？

**Visual**:
- [ ] 推奨フォントを使用しているか？
- [ ] CSS変数でスタイルを管理しているか？
- [ ] OKLCH色空間またはコントラスト比4.5:1を満たしているか？
- [ ] 4ptベースユニットでスペーシングしているか？

**Motion**:
- [ ] アニメーションは高インパクトな瞬間に集中しているか？
- [ ] `prefers-reduced-motion`を考慮しているか？
- [ ] 100/300/500ルールに沿った持続時間か？

**品質**（詳細は各reference/を参照）:
- [ ] インタラクション状態（8状態）を考慮したか？→ `reference/interaction-design.md`
- [ ] レスポンシブ対応しているか？→ `reference/responsive-design.md`
- [ ] WCAG AA準拠か？→ `reference/accessibility.md`
- [ ] パフォーマンスを考慮したか？→ `reference/performance.md`

---

## References

### 公式・主要ソース
- [Improving frontend design through Skills](https://claude.com/blog/improving-frontend-design-through-skills)
- [Prompting for frontend aesthetics](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics)
- [anthropics/skills](https://github.com/anthropics/skills)
- [pbakaus/impeccable](https://github.com/pbakaus/impeccable) — 8.5k★、7参照ファイル構成

### reference/ ファイル
- `reference/interaction-design.md` — インタラクション設計（8状態、フォーム、モーダル）
- `reference/responsive-design.md` — レスポンシブデザイン（モバイルファースト、fluid typography）
- `reference/accessibility.md` — アクセシビリティ（WCAG AA、キーボード、スクリーンリーダー）
- `reference/ux-writing.md` — UXライティング（ボタンラベル、エラーメッセージ、空状態）
- `reference/performance.md` — パフォーマンス（Core Web Vitals、フォント、画像）
- `reference/dark-mode.md` — ダークモード実装（CSS light-dark()、FOUC防止）
