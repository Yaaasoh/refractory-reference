# Dark Mode Reference

ダークモード実装の具体的なガイド。

---

## 実装アプローチ

### 推奨: CSS `light-dark()`（最新）

```css
:root { color-scheme: light dark; }

body {
  background: light-dark(#ffffff, #0f172a);
  color: light-dark(#1e293b, #f8fafc);
}
```

- JS不要、ブラウザのシステム設定に自動追従
- 2024年以降の全モダンブラウザで対応

### 確立手法: CSS変数 + `prefers-color-scheme`

```css
:root {
  --bg: #ffffff;
  --text: #1e293b;
  --surface: #f1f5f9;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg: #0f172a;
    --text: #f8fafc;
    --surface: #1e293b;
  }
}
```

### ユーザー制御: `data-theme` トグル

```css
[data-theme="dark"] {
  --bg: #0f172a;
  --text: #f8fafc;
}
```

```js
// トグル
document.documentElement.dataset.theme =
  document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark'
```

---

## FOUC防止（Flash of Unstyled Content）

`<head>` 内のインラインスクリプトでテーマを即座に適用:

```html
<head>
  <script>
    const theme = localStorage.getItem('theme')
      || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
    document.documentElement.dataset.theme = theme
  </script>
</head>
```

- `<body>` レンダリング前に実行されるため、ちらつきが発生しない
- Next.js: `cookies()` でサーバーサイド永続化（localStorage不可のSSR対策）

---

## ダークモード特有のデザイン原則

### 深度表現
- ライトモード: 影で深度を表現
- **ダークモード**: 明るいサーフェスで深度を表現（影は見えにくい）

```css
[data-theme="dark"] {
  --surface-1: oklch(0.15 0.01 250);  /* 最も低い */
  --surface-2: oklch(0.20 0.01 250);  /* 中間 */
  --surface-3: oklch(0.25 0.01 250);  /* 最も高い（手前） */
}
```

### テキスト
- font-weight を少し軽く（dark-on-light は太く見える）
- 純白 `#ffffff` は避ける → `#f8fafc` 等でわずかに抑える

### カラー
- アクセントカラーの彩度を10-15%下げる
- 純粋な高彩度色は目を疲れさせる

### 画像
- `filter: brightness(0.85)` で少し暗くする（オプション）
- 白背景の画像は `border-radius` + `border` で馴染ませる

---

## スタック別推奨

| スタック | 推奨手法 |
|---------|---------|
| 静的サイト | CSS `light-dark()` + localStorage |
| React SPA | CSS変数 + `data-theme` + Context |
| Tailwind CSS | `dark:` variant + `class` strategy |
| Next.js | `next-themes` ライブラリ + cookies |

---

## Tailwind CSS設定

```js
// tailwind.config.js
module.exports = {
  darkMode: 'class',  // 'media' ではなく 'class' を推奨
}
```

```html
<html class="dark">
  <body class="bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-50">
  </body>
</html>
```

---

## 永続化

```js
// localStorage（クライアントサイド）
function setTheme(theme) {
  document.documentElement.dataset.theme = theme
  localStorage.setItem('theme', theme)
}

// 初期化: ユーザー設定 > システム設定
function initTheme() {
  return localStorage.getItem('theme')
    || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
}
```

- **3段階フォールバック**: ユーザー明示選択 > システム設定 > ライトモード
