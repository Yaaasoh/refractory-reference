# Accessibility Reference

WCAG AA準拠のアクセシビリティ実装ガイド。

---

## コントラスト比要件（WCAG AA）

| 要素 | 最小比率 |
|------|---------|
| 本文テキスト（<18pt） | 4.5:1 |
| 大テキスト（≥18pt bold / ≥24pt） | 3:1 |
| UIコンポーネント・グラフィカルオブジェクト | 3:1 |
| 非活性要素・装飾 | 要件なし |

**ツール**: WebAIM Contrast Checker, Chrome DevTools Accessibility

---

## セマンティックHTML

```html
<body>
  <a href="#main" class="skip-link">メインコンテンツへ</a>
  <header><!-- サイトヘッダー --></header>
  <nav aria-label="メインナビゲーション"><!-- ナビ --></nav>
  <main id="main">
    <h1>ページタイトル</h1>
    <article><!-- コンテンツ --></article>
    <aside><!-- サイドバー --></aside>
  </main>
  <footer><!-- フッター --></footer>
</body>
```

- ランドマーク要素（`<header>`, `<nav>`, `<main>`, `<footer>`）を使用
- スクリーンリーダーユーザーの70%が見出しでナビゲーション

---

## 見出し階層

- `<h1>` はページに1つ
- レベルを飛ばさない（h1→h3は不可、h1→h2→h3）
- 見出しは視覚的な大きさではなく**意味的な階層**で選択

---

## ARIA

**原則**: セマンティックHTML優先。ARIAは補完のみ

```html
<!-- ❌ 悪い例: divにARIA -->
<div role="button" tabindex="0">送信</div>

<!-- ✅ 正しい例: ネイティブ要素 -->
<button>送信</button>
```

### 有用なARIA属性

| 属性 | 用途 |
|------|------|
| `aria-label` | 可視テキストのない要素にラベル |
| `aria-describedby` | 補足説明（エラーメッセージ等）の関連付け |
| `aria-live="polite"` | 動的に変化するコンテンツの通知 |
| `aria-expanded` | 折りたたみ/展開状態 |
| `aria-hidden="true"` | 装飾要素をスクリーンリーダーから隠す |
| `aria-invalid="true"` | フォームフィールドのエラー状態 |

---

## フォーカス管理

- `:focus-visible` を使用（`:focus` はマウスクリック時も発火する）
- 動的UIコンテンツ変更後、適切な要素にフォーカスを移動
- フォーカストラップ: モーダル内でTabが循環するように

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

---

## 色に依存しない情報伝達

色だけで情報を伝えない。アイコン・テキスト・パターンを併用:

```html
<!-- ❌ 色だけ -->
<span style="color: red">エラー</span>

<!-- ✅ 色 + アイコン + テキスト -->
<span class="error">
  <svg aria-hidden="true"><!-- エラーアイコン --></svg>
  入力に誤りがあります
</span>
```

---

## キーボード操作

- すべてのインタラクティブ要素がキーボードで操作可能
- フォーカス順序が論理的（DOM順序 = 視覚順序）
- `tabindex="0"`: フォーカス可能にする
- `tabindex="-1"`: プログラム的にフォーカス可能（Tab順序には含まない）
- `tabindex` > 0 は使わない

---

## 動的コンテンツの通知

トースト/スナックバー/ライブ更新:

```html
<div role="status" aria-live="polite">
  保存しました
</div>

<div role="alert" aria-live="assertive">
  エラー: 接続が失われました
</div>
```

- `polite`: 現在の作業を中断しない
- `assertive`: 即座に通知（エラー等）

---

## prefers-reduced-motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## テストツール

| ツール | 用途 |
|-------|------|
| axe DevTools | 自動アクセシビリティ検査 |
| WebAIM Contrast Checker | コントラスト比確認 |
| NVDA / VoiceOver | スクリーンリーダー手動テスト |
| Lighthouse Accessibility | スコアリング |
| Tab キー | フォーカス順序の確認 |
