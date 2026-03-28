# design-token-validator Skill

**Version**: 1.0.0
**Author**: prompt-patterns

---

## Description

デザイントークン（CSS変数、Tailwind設定）の命名規則・構造を検証し、
一貫性のあるデザインシステムを維持するためのSkill。

**トリガー**:
- CSS変数の追加・変更
- Tailwind設定の更新
- デザインシステムのレビュー
- スタイル一貫性の確認

---

## Token Structure

### 2層構造（推奨）

```
Layer 1: Primitive Tokens（基本値）
  └── 色、サイズ、フォントなどの生の値

Layer 2: Semantic Tokens（意味的な値）
  └── Primitiveを参照し、用途を示す名前
```

### 例

```css
/* ===== Layer 1: Primitive Tokens ===== */
:root {
  /* Colors - Raw values */
  --ds-color-blue-50: #EFF6FF;
  --ds-color-blue-500: #3B82F6;
  --ds-color-blue-600: #2563EB;
  --ds-color-blue-900: #1E3A8A;

  /* Spacing - Raw values */
  --ds-spacing-1: 4px;
  --ds-spacing-2: 8px;
  --ds-spacing-3: 12px;
  --ds-spacing-4: 16px;
  --ds-spacing-6: 24px;
  --ds-spacing-8: 32px;

  /* Radius - Raw values */
  --ds-radius-sm: 4px;
  --ds-radius-md: 8px;
  --ds-radius-lg: 12px;
  --ds-radius-full: 9999px;

  /* Font Size - Raw values */
  --ds-font-size-sm: 0.875rem;
  --ds-font-size-base: 1rem;
  --ds-font-size-lg: 1.125rem;
  --ds-font-size-xl: 1.25rem;
}

/* ===== Layer 2: Semantic Tokens ===== */
:root {
  /* Colors - Semantic */
  --color-primary: var(--ds-color-blue-500);
  --color-primary-hover: var(--ds-color-blue-600);
  --color-background: var(--ds-color-blue-900);
  --color-surface: var(--ds-color-blue-50);

  /* Component-specific */
  --button-padding-x: var(--ds-spacing-4);
  --button-padding-y: var(--ds-spacing-2);
  --button-radius: var(--ds-radius-md);

  --card-padding: var(--ds-spacing-6);
  --card-radius: var(--ds-radius-lg);

  --input-padding: var(--ds-spacing-3);
  --input-radius: var(--ds-radius-md);
}
```

---

## Naming Convention

### 命名パターン

```
[namespace]-[category]-[property]-[variant]-[state]
```

### 各部分の説明

| 部分 | 説明 | 例 |
|------|------|-----|
| namespace | プロジェクト/デザインシステム識別子 | `ds`, `app`, `brand` |
| category | トークンカテゴリ | `color`, `spacing`, `font`, `radius` |
| property | 具体的なプロパティ | `blue`, `primary`, `size` |
| variant | バリエーション | `50`, `500`, `sm`, `lg` |
| state | 状態（オプション） | `hover`, `active`, `disabled` |

### 例

```css
/* Primitive: namespace-category-property-variant */
--ds-color-blue-500
--ds-spacing-4
--ds-radius-md

/* Semantic: component-category-role */
--button-color-primary
--button-color-primary-hover
--card-spacing-padding
--input-radius-default
```

---

## Validation Rules

### Rule 1: 命名規則の一貫性

**Valid**:
```css
--ds-color-blue-500: #3B82F6;
--ds-color-blue-600: #2563EB;
--ds-spacing-4: 16px;
```

**Invalid**:
```css
--blue500: #3B82F6;        /* ❌ namespaceなし、ハイフンなし */
--ds-Blue-500: #3B82F6;    /* ❌ 大文字使用 */
--ds_color_blue: #3B82F6;  /* ❌ アンダースコア使用 */
```

### Rule 2: Semantic Tokenはプリミティブを参照

**Valid**:
```css
--color-primary: var(--ds-color-blue-500);
```

**Invalid**:
```css
--color-primary: #3B82F6;  /* ❌ 直接値を指定 */
```

### Rule 3: スケールの一貫性

**Valid**（4pxグリッド）:
```css
--ds-spacing-1: 4px;
--ds-spacing-2: 8px;
--ds-spacing-3: 12px;
--ds-spacing-4: 16px;
```

**Invalid**:
```css
--ds-spacing-1: 4px;
--ds-spacing-2: 7px;   /* ❌ 4pxグリッドに非準拠 */
--ds-spacing-3: 15px;  /* ❌ 4pxグリッドに非準拠 */
```

### Rule 4: 色のコントラスト

- テキストと背景のコントラスト比: 4.5:1以上（WCAG AA）
- 大きなテキスト（18px以上）: 3:1以上

---

## Validation Checklist

CSS変数追加・変更時の確認:

### 構造
- [ ] 2層構造（Primitive/Semantic）を維持しているか？
- [ ] Semantic TokenはPrimitive Tokenを参照しているか？

### 命名
- [ ] 命名規則に従っているか？（小文字、ハイフン区切り）
- [ ] namespaceが統一されているか？
- [ ] カテゴリ名が適切か？

### 一貫性
- [ ] スペーシングが基本グリッド（4px）に準拠しているか？
- [ ] 色のスケールが一貫しているか？（50-900等）
- [ ] 類似トークンの命名が一貫しているか？

### アクセシビリティ
- [ ] テキスト/背景のコントラスト比は十分か？
- [ ] フォーカス状態の視覚的区別があるか？

---

## Tailwind Integration

### tailwind.config.js との連携

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // Semantic tokensをTailwindに統合
        primary: {
          DEFAULT: 'var(--color-primary)',
          hover: 'var(--color-primary-hover)',
        },
        background: 'var(--color-background)',
        surface: 'var(--color-surface)',
      },
      spacing: {
        'button-x': 'var(--button-padding-x)',
        'button-y': 'var(--button-padding-y)',
        'card': 'var(--card-padding)',
      },
      borderRadius: {
        'button': 'var(--button-radius)',
        'card': 'var(--card-radius)',
        'input': 'var(--input-radius)',
      },
    },
  },
}
```

### 使用例

```jsx
<button className="px-button-x py-button-y rounded-button bg-primary hover:bg-primary-hover">
  Click me
</button>

<div className="p-card rounded-card bg-surface">
  Card content
</div>
```

---

## Common Issues

### Issue 1: Magic Numbers

**問題**:
```css
.button {
  padding: 14px 22px;  /* ❌ Magic numbers */
}
```

**解決**:
```css
.button {
  padding: var(--button-padding-y) var(--button-padding-x);
}
```

### Issue 2: Hardcoded Colors

**問題**:
```css
.card {
  background: #f8fafc;  /* ❌ Hardcoded */
  border: 1px solid #e2e8f0;
}
```

**解決**:
```css
.card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
}
```

### Issue 3: Inconsistent Spacing

**問題**:
```css
.section { margin-bottom: 17px; }  /* ❌ 4pxグリッド非準拠 */
.item { margin-bottom: 13px; }     /* ❌ 4pxグリッド非準拠 */
```

**解決**:
```css
.section { margin-bottom: var(--ds-spacing-4); }  /* 16px */
.item { margin-bottom: var(--ds-spacing-3); }     /* 12px */
```

---

## Audit Command

デザイントークンの検証を実行:

```bash
# CSSファイル内のトークン使用状況を確認
grep -r "var(--" src/styles/ | grep -v "var(--ds-\|var(--color-\|var(--button-"
# → Semantic tokenを使用していない箇所を検出

# ハードコードされた色を検出
grep -rE "#[0-9a-fA-F]{3,6}" src/components/ --include="*.tsx" --include="*.css"
# → CSS変数に置き換えるべき箇所を検出

# Magic numbers（スペーシング）を検出
grep -rE "margin|padding.*[0-9]+px" src/components/ --include="*.tsx" --include="*.css"
# → トークンに置き換えるべき箇所を検出
```

---

## References

- [Design Tokens W3C Community Group](https://www.w3.org/community/design-tokens/)
- [Figma Variables](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
- [Tailwind CSS Configuration](https://tailwindcss.com/docs/configuration)
