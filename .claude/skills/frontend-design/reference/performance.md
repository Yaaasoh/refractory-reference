# Performance Reference

フロントエンドパフォーマンスの実装ガイド。

---

## Core Web Vitals（2026）

| 指標 | 良好 | 要改善 | 不良 |
|------|------|--------|------|
| **INP** (Interaction to Next Paint) | <200ms | 200-500ms | >500ms |
| **LCP** (Largest Contentful Paint) | <2.5s | 2.5-4s | >4s |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1-0.25 | >0.25 |

---

## フォントローディング

```html
<!-- Preload critical fonts -->
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin />
```

```css
@font-face {
  font-family: 'MainFont';
  src: url('/fonts/main.woff2') format('woff2');
  font-display: swap;          /* FOUT > FOIT */
  unicode-range: U+0000-00FF;  /* Latin subset */
}
```

- **Variable Fonts推奨**: 1ファイルで全weight（ファイルサイズ削減）
- `font-display: swap` 必須（FOITを避ける）
- `unicode-range` でサブセット配信

---

## 画像最適化

**フォーマット優先順位**: AVIF > WebP > JPEG/PNG

```html
<img src="photo.webp" alt="説明"
  width="800" height="400"
  loading="lazy"
  decoding="async" />
```

- Above-the-fold画像: `loading="eager"` + `fetchpriority="high"`
- Below-the-fold画像: `loading="lazy"`
- **必ず** `width`/`height` 属性を指定（CLS防止）
- `srcset` + `sizes` で適切なサイズを配信

---

## CSS最適化

### Critical CSS
```html
<head>
  <!-- Critical CSS inline -->
  <style>/* above-the-fold styles */</style>
  <!-- Non-critical CSS deferred -->
  <link rel="preload" href="styles.css" as="style" onload="this.rel='stylesheet'" />
</head>
```

### 未使用CSS除去
- PurgeCSS / Tailwind JIT で未使用クラスを除去
- Coverage DevToolで未使用率を確認

---

## バンドルサイズ目標

| サイトタイプ | JS + CSS 目標 |
|-------------|:------------:|
| ランディングページ | <200KB |
| E-commerce | <500KB |
| コンテンツサイト | <750KB |
| SaaSダッシュボード | <1MB |

- **Tree shaking**: 未使用エクスポートを除去
- **Code splitting**: ルート単位で分割
- **Dynamic import**: 必要時にロード

---

## アニメーションパフォーマンス

**GPU composited プロパティのみ使用**:
- `transform`
- `opacity`
- `filter`

**避けるべきプロパティ**（レイアウト再計算を引き起こす）:
- `width`, `height`
- `top`, `left`
- `margin`, `padding`

```css
/* ✅ transform で移動 */
.slide-in { transform: translateX(0); }

/* ❌ left で移動（レイアウト再計算） */
.slide-in { left: 0; }
```

`will-change` は控えめに（本当に必要な場合のみ）。

---

## 圧縮

| 方式 | 静的ファイル | 動的レスポンス |
|------|:----------:|:------------:|
| **Brotli** | level 9-11 | level 4-6 |
| **gzip** | level 9 | level 6 |

Brotliを優先（gzipより15-25%小さい）。

---

## その他

- **Prefetch/Preconnect**: 次ページのリソースを事前取得
- **Service Worker**: オフライン対応、キャッシュ戦略
- **Resource Hints**: `<link rel="dns-prefetch">` で外部ドメイン解決を事前実行
