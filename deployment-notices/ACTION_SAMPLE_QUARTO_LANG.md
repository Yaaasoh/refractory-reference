---
target_tools: [quarto, qmd]
target_features: []
action: recommended
expires: 2026-06-01
---

# ACTION: Quarto言語設定の確認

## 必要なアクション
1. `_quarto.yml` に `lang: ja` が設定されていることを確認
2. 未設定の場合は追加

## 確認コマンド
```bash
grep -q "lang: ja" _quarto.yml && echo "OK" || echo "要設定"
```
