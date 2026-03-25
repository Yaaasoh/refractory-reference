# UPDATE: 学習メモ正本パスの明記（全リポジトリ対象）

**日付**: 2026-03-20
**対象**: 全リポジトリ
**背景**: CLAUDE.mdの`## 学習メモ`セクションに正本パスが記載されていないため、Claudeが学習メモの保存先を発見できず、ATONEMENT_SYSTEM.mdを誤認する等の障害が発生。

## 問題

CLAUDE.mdの学習メモセクションが以下のように不完全:

```markdown
## 学習メモ

（セッションで学んだ知見を追記）
```

正本パスも運用ルールも記載されておらず、Claudeが学習メモの仕組みを理解できない。

## 対応（全リポジトリ共通）

CLAUDE.mdの`## 学習メモ`セクションを以下に更新:

```markdown
## 学習メモ

**正本**: `work/learning-notes/LEARNING_NOTES.md`
**運用ルール**:
- 新規メモはここに追記
- 5件を超えたら古い項目をLEARNING_NOTES.mdに移動
- 移動時に「shared/rules/に反映すべき教訓はないか」を確認

### 直近の学習メモ

（セッションで学んだ知見を追記）
```

正本ファイルが存在しない場合は作成:

```bash
mkdir -p work/learning-notes
cat > work/learning-notes/LEARNING_NOTES.md << 'EOF'
# 学習メモ（正本）

**正本**: このファイルが学習メモの正本です。
**参照元**: `CLAUDE.md` の「学習メモ」セクションから参照されます。
**運用**: CLAUDE.md内のメモが5件を超えたら、古い項目をこのファイルに移動してください。

---
EOF
```

## 注意

- `ATONEMENT_SYSTEM.md`（罪の記録）は学習メモではない。混同しない
- CLAUDE.md 400行超のリポジトリは別途 UPDATE_20260317 の分離手順も参照
