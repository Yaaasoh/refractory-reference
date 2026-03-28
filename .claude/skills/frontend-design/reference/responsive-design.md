# Responsive Design Reference

レスポンシブデザインの実装ガイド。

---

## モバイルファースト

ベーススタイルはモバイル向け。`min-width` メディアクエリで拡張:

```css
/* Base: mobile */
.container { padding: 16px; }

/* Tablet */
@media (min-width: 768px) {
  .container { padding: 24px; }
}

/* Desktop */
@media (min-width: 1024px) {
  .container { padding: 32px; max-width: 1200px; }
}
```

---

## ブレークポイント

コンテンツ駆動で決定。デバイス固有ではなく、レイアウトが崩れる地点で設定:

| 名前 | 値 | 目安 |
|------|-----|------|
| sm | 640px | 大きなスマートフォン |
| md | 768px | タブレット |
| lg | 1024px | 小さなデスクトップ |
| xl | 1280px | デスクトップ |
| 2xl | 1536px | 大画面 |

---

## Fluid Typography

固定サイズではなく、ビューポートに応じてスケール:

```css
h1 { font-size: clamp(2rem, 5vw, 3.5rem); }
h2 { font-size: clamp(1.5rem, 3vw, 2.5rem); }
p  { font-size: clamp(1rem, 1.5vw, 1.125rem); }
```

- `clamp(min, preferred, max)` で最小値・最大値を保証
- `vw` 単位で滑らかなスケーリング

---

## 入力検出

タッチデバイスとマウスデバイスでUIを分岐:

```css
/* マウスデバイスのみhoverエフェクト */
@media (hover: hover) and (pointer: fine) {
  .card:hover { transform: translateY(-2px); }
}

/* タッチデバイス: より大きなタップターゲット */
@media (pointer: coarse) {
  .button { min-height: 44px; min-width: 44px; }
}
```

---

## Container Queries

コンポーネント単位のレスポンシブ（親コンテナの幅に応じて変化）:

```css
.card-container { container-type: inline-size; }

@container (min-width: 400px) {
  .card { display: grid; grid-template-columns: 1fr 2fr; }
}
```

---

## タッチ対応

- **最小タップターゲット**: 44x44px（WCAG 2.5.8）
- **Thumb Zone**: モバイルでは画面下部に主要アクションを配置
- **スワイプ**: ネイティブスクロールを妨げない
- **ピンチズーム**: `user-scalable=no` は使わない

---

## レスポンシブ画像

```html
<picture>
  <source srcset="hero-large.avif" media="(min-width: 1024px)" type="image/avif" />
  <source srcset="hero-medium.avif" media="(min-width: 640px)" type="image/avif" />
  <img src="hero-small.webp" alt="ヒーロー画像"
    loading="lazy" decoding="async"
    width="800" height="400" />
</picture>
```

- `srcset` + `sizes` で適切なサイズを配信
- AVIF > WebP > JPEG の優先順位
- `width`/`height` 属性でCLS防止

---

## Safe Area Insets

ノッチ/ダイナミックアイランド対応:

```css
body {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}
```
