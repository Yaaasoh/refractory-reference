# UPDATE: CLAUDE.md学習メモ分離手順書

**日付**: 2026-03-17
**対象**: CLAUDE.md 400行超のリポジトリ
**背景**: IFScale論文の知見により、150-200ディレクティブでprimacy bias（先頭指示の偏重）が顕著化することが判明。CLAUDE.mdの肥大化は指示遵守率を低下させる。

## 判断基準

`wc -l CLAUDE.md` → **400行超で分離を推奨**

### 対象リポジトリ（2026-03-17時点）

| リポジトリ | 行数 | 状態 |
|-----------|:----:|------|
| transcription-workspace | 867 | 要対応 |
| prompt-patterns | 778→369 | 対応済み |
| ocr-app | 614 | 要対応 |
| facility-safety | 441 | 要対応 |

## 分離手順（各リポで単独実行可能）

### Step 1: 行数確認

```bash
wc -l CLAUDE.md
```

400行以下なら分離不要。

### Step 2: 学習メモセクションの開始行を特定

```bash
grep -n "## 学習メモ" CLAUDE.md
```

セクション名が異なる場合（「## セッション記録」等）は適宜読み替える。

### Step 3: 分離先ファイルを作成

```bash
mkdir -p work/learning-notes
```

学習メモセクション全体を `work/learning-notes/LEARNING_NOTES.md` にコピー。
先頭にヘッダーを追加:

```markdown
# 学習メモ（正本）

**正本**: このファイルが学習メモの正本です。
**参照元**: `CLAUDE.md` の「学習メモ」セクションから参照されます。
**運用**: CLAUDE.md内のメモが5件を超えたら、古い項目をこのファイルに移動してください。

---
```

### Step 4: CLAUDE.mdの学習メモを軽量化

学習メモセクションを以下に置換:

```markdown
## 学習メモ

**正本**: `work/learning-notes/LEARNING_NOTES.md`（YYYY-MM-DD〜YYYY-MM-DD、N件）
**運用ルール**:
- 新規メモはここに追記
- 5件を超えたら古い項目をLEARNING_NOTES.mdに移動
- 移動時に「shared/rules/に反映すべき教訓はないか」を確認

### 直近の学習メモ

（直近3件を要約形式で残す）
```

### Step 5: 行数確認

```bash
wc -l CLAUDE.md
```

400行以下であることを確認。

## 分離前チェックリスト

分離前に、削除する学習メモの中に以下に反映すべき教訓がないか確認:

- [ ] `shared/rules/` のルールファイル — 繰り返し発生する問題パターン
- [ ] `MEMORY.md` — ユーザーの好み、プロジェクト固有の知識
- [ ] `.claude/settings.json` — 権限設定、hook設定

## shared/rules/ の更新（2026-03-17）

本通知と同時に以下のrules/ファイルが更新されています:

- `evidence-based-thinking.md` v2.1: WebSearch結果100%保存義務、コマンド存在確認義務を追加
- `plan-mode.md` v1.1: 「計画承認≠実装許可」のフェーズ境界を明記
- `deployment.md` v1.1: 「ファイル配置≠有効化」、deploy.sh -f使用禁止を追加

これらは deploy.sh により自動配置済みです。
