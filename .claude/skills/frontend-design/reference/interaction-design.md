# Interaction Design Reference

フロントエンド実装時のインタラクション設計ガイド。

---

## 8つの必須状態

すべてのインタラクティブ要素は以下の状態を考慮すること:

| 状態 | 説明 | 実装ポイント |
|------|------|-------------|
| **Default** | 初期状態 | 明確なアフォーダンス |
| **Hover** | マウスオーバー | `@media (hover: hover)` でタッチデバイスと分離 |
| **Focus** | キーボードフォーカス | `:focus-visible` のみ（`:focus` は避ける） |
| **Active** | クリック/タップ中 | 即座のフィードバック（scale 0.97等） |
| **Disabled** | 操作不可 | `opacity: 0.5` + `cursor: not-allowed` + `aria-disabled` |
| **Loading** | 処理中 | スケルトン > スピナー。楽観的UIを検討 |
| **Error** | エラー発生 | フィールドレベル + フォームサマリの両方 |
| **Empty** | データなし | 次のアクションへ導く（オンボーディング機会） |

---

## Focus Rings

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* マウスクリック時は非表示 */
:focus:not(:focus-visible) {
  outline: none;
}
```

- コントラスト比 3:1以上
- `outline-offset` で要素と間隔を確保

---

## フォーム設計

### 必須事項
- 可視 `<label>` 必須（placeholder単独は不可）
- バリデーションは `blur` 時（入力中は行わない）
- エラーメッセージは `aria-describedby` で関連付け

### エラー表示
```html
<div>
  <label for="email">メールアドレス</label>
  <input id="email" type="email"
    aria-invalid="true"
    aria-describedby="email-error" />
  <p id="email-error" role="alert">有効なメールアドレスを入力してください</p>
</div>
```

---

## ローディングパターン

**優先順位**: スケルトンスクリーン > 楽観的UI > プログレスバー > スピナー

```tsx
// スケルトンスクリーン例
function CardSkeleton() {
  return (
    <div className="animate-pulse">
      <div className="h-48 bg-surface-raised rounded-lg" />
      <div className="mt-4 h-4 bg-surface-raised rounded w-3/4" />
      <div className="mt-2 h-4 bg-surface-raised rounded w-1/2" />
    </div>
  )
}
```

---

## モーダル/ダイアログ

- native `<dialog>` 要素を使用
- `inert` 属性で背景コンテンツを無効化
- `Escape` キーで閉じる
- 開いた時にフォーカスをダイアログ内に移動
- 閉じた時にトリガー要素にフォーカスを戻す

```html
<dialog id="confirm-dialog">
  <h2>確認</h2>
  <p>この操作は取り消せません。</p>
  <button autofocus>キャンセル</button>
  <button>実行</button>
</dialog>
```

---

## 空状態の4タイプ

| タイプ | 例 | 推奨アクション |
|-------|-----|---------------|
| 初回利用 | 「まだプロジェクトがありません」 | 作成ボタン + 説明 |
| 検索結果なし | 「条件に一致する結果がありません」 | 条件変更の提案 |
| データなし | 「この期間のデータがありません」 | 別の期間の提案 |
| エラー | 「データの読み込みに失敗しました」 | リトライボタン |

---

## キーボードナビゲーション

- **Tab**: フォーカス移動（論理順序）
- **Enter/Space**: アクティベーション
- **Escape**: モーダル/ポップオーバー閉じ
- **矢印キー**: リスト内/タブ内移動（Roving tabindex）
- **スキップリンク**: ページ先頭に「メインコンテンツへ」リンク
