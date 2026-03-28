# Frontend Aesthetics - CLAUDE.md テンプレート

**作成日**: 2026-01-18
**用途**: CLAUDE.mdに追加してフロントエンドデザイン品質を向上

---

## 使用方法

以下のセクションをプロジェクトのCLAUDE.mdにコピーして使用する。

---

## テンプレート本体

```markdown
## Frontend Design Standards

### AI Slop回避

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

### Design Thinking（コーディング前の必須思考）

フロントエンド実装前に以下を明確にすること:

1. **Purpose**: このインターフェースが解決する問題は何か？誰が使うか？
2. **Tone**: 美学的方向性を選択（以下から1つ）
   - Brutally minimal（極限のミニマル）
   - Maximalist chaos（最大主義的カオス）
   - Retro-futuristic（レトロフューチャー）
   - Organic/natural（オーガニック/自然）
   - Luxury/refined（ラグジュアリー/洗練）
   - Playful/toy-like（遊び心/おもちゃ的）
   - Dark & moody（暗くムーディー）
   - Artisanal/crafted（職人的/手作り感）
3. **Constraints**: 技術的制約（フレームワーク、パフォーマンス、アクセシビリティ）
4. **Differentiation**: 何がこのUIを忘れられないものにするか？

### Typography Guidelines

#### 推奨フォント

| カテゴリ | フォント | 用途 |
|---------|---------|------|
| **Code/Tech** | JetBrains Mono, Fira Code, Space Grotesk | 技術系、開発ツール |
| **Editorial** | Playfair Display, Crimson Pro, Fraunces | コンテンツ、記事 |
| **Modern/Startup** | Clash Display, Satoshi, Cabinet Grotesk | SaaS、スタートアップ |
| **Geometric** | Outfit, Manrope, Plus Jakarta Sans | クリーン、モダン |

#### 回避すべきフォント

- Inter（過度に使用されている）
- Roboto（Googleデフォルト感）
- Arial（システムフォント感）
- Open Sans（無個性）

### Color & Theme Guidelines

#### CSS変数の使用

```css
:root {
  /* Primitive tokens */
  --color-blue-500: #3B82F6;
  --color-blue-600: #2563EB;

  /* Semantic tokens */
  --color-primary: var(--color-blue-500);
  --color-primary-hover: var(--color-blue-600);
  --color-background: #0F172A;
  --color-surface: #1E293B;
  --color-text-primary: #F8FAFC;
  --color-text-secondary: #94A3B8;
}
```

#### カラー選択の原則

1. **支配色を決める**: 1つの主要色を選び、大胆に使用
2. **シャープなアクセント**: コントラストの高いアクセントカラー
3. **一貫性**: 全コンポーネントで同一パレット使用
4. **ダークモード考慮**: 両モード対応の場合は最初から設計

### Motion Guidelines

#### 推奨パターン

```jsx
// Framer Motion + Tailwind
import { motion } from "framer-motion"

// ページロード時のstaggered reveal
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3, delay: index * 0.1 }}
>
```

#### アニメーション原則

1. **高インパクトな瞬間に集中**: ページロード、重要なインタラクション
2. **staggered reveals**: `animation-delay`で段階的表示
3. **transform優先**: `width/height`より`transform`を使用
4. **200-400ms**: 適切なデュレーション範囲
5. **prefers-reduced-motion対応**: アクセシビリティ考慮

### 回避すべきパターン

1. **Generic layouts**: 全要素が整列した予測可能なグリッド
2. **Purple-on-white**: 白背景に紫グラデーション
3. **Scattered micro-interactions**: 一貫性のない小さなアニメーション
4. **Solid color backgrounds**: 深みのない単色背景
5. **Safe choices**: 「無難」な選択の積み重ね
```

---

## カスタマイズガイド

### プロジェクト固有の調整

1. **フォント**: プロジェクトのブランドに合わせて推奨フォントを変更
2. **カラー**: ブランドカラーに合わせてCSS変数を調整
3. **Tone**: プロジェクトの性質に合った美学的方向性を固定

### 例: SaaS Dashboard向けカスタマイズ

```markdown
### Project-Specific Design Direction

- **Tone**: Brutally minimal + Dark & moody
- **Primary Font**: Space Grotesk (headings), Inter (body is acceptable for data-heavy UI)
- **Color Palette**: Deep navy base (#0a1628), electric cyan accents (#00d4ff)
- **Motion**: Subtle transitions only, no decorative animations (performance priority)
```

### 例: マーケティングサイト向けカスタマイズ

```markdown
### Project-Specific Design Direction

- **Tone**: Playful/toy-like + Maximalist
- **Primary Font**: Clash Display (headings), Satoshi (body)
- **Color Palette**: Vibrant gradients, bold contrasts
- **Motion**: Elaborate page transitions, scroll-triggered animations
```

---

## 参照

| リソース | URL |
|---------|-----|
| 公式プロンプティングガイド | [Prompting for frontend aesthetics](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics) |
| frontend-design Skill | [anthropics/skills](https://github.com/anthropics/skills) |
| 関連調査 | `work/research/claude-code-design-capabilities/` |

---

**ステータス**: テンプレート完成
