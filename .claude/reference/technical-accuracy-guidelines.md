# 統合技術精度ガイドライン（Claude Code CLI版）

## 0. Claude Code CLI環境理解

### 🚨 ファイル分離保存の鉄則

#### 環境の特徴
Claude Code CLI環境では、ローカルファイルシステムに直接ファイルを作成します：

- **プロジェクトディレクトリ**:
  - 実際の作業ディレクトリ（例: `C:\Users\username\github\project\`）
  - Gitで管理される実ファイル
  - 完全なパス指定が重要

- **ツールの使用**:
  - `Write()`: 新規ファイル作成
  - `Edit()`: 既存ファイルの編集
  - `Read()`: ファイルの読み取り
  - `Glob()`: ファイルの検索

#### ファイル分離保存の具体的方法

**✅ 正しい例**:
```python
# Claude Code CLIでの実装
Write(
    file_path="C:\\Users\\username\\github\\project\\src\\api-handler.py",
    content=long_code
)

# または相対パスが明確な場合
Write(
    file_path="src/api-handler.py",
    content=long_code
)
```

**❌ 避けるべき例**:
```python
# Web UI向けの記述（CLI環境では動作しない）
create_file(
    path="/mnt/user-data/outputs/api-handler.py",  # ❌ CLI環境に存在しない
    file_text=long_code
)

# パス不明確（現在のディレクトリに依存）
Write(
    file_path="api-handler.py",  # ❌ どこに作成されるか不明確
    content=long_code
)
```

#### ファイル名の絶対規則

1. **最大長**: 100文字以内（Windowsの`MAX_PATH`制限を考慮）
2. **形式**: `[project]-[type]-[version].[ext]`
3. **使用可能文字**: a-z, 0-9, -, _（英小文字推奨）
4. **禁止文字**: 空白、特殊文字（Windows・Linuxパス制限を考慮）

**例**:
- ✅ `api-spec-v1.md` (14文字)
- ✅ `auth-module.py` (14文字)
- ✅ `database-schema.sql` (18文字)
- ❌ `technical accuracy guidelines for comprehensive projects.md` (空白含む)

#### 作成前チェックリスト（30秒）

実行前に必ず確認：
- [ ] パスは絶対パスか、明確な相対パスか？
- [ ] ファイル名は100文字以内か？
- [ ] 拡張子は適切か？（.md, .py, .yaml, .json等）
- [ ] ファイル名に空白や特殊文字はないか？
- [ ] 作業ディレクトリは正しいか？

#### 失敗時の診断手順

ファイル作成・編集が失敗した場合：
1. エラーメッセージを確認
2. 上記チェックリストを再確認
3. 絶対パスで再指定（例: `C:\Users\...\file.py`）
4. パス区切りを確認（Windows: `\` or `/`、Linux/Mac: `/`）
5. ファイル名を短縮・簡素化

## 1. 統合品質原則

### 技術精度 + 表示安全性の同時確保
- **確認優先**: 不明点は推測せず、技術・マークダウン両方を検証
  - **詳細**: `docs/rules/evidence-based-thinking.md` - Read First, Code Later原則
- **ファイル分離優先**: 複雑な内容は必ず別ファイルで提供
- **分割記述**: 複雑な構造は段階的に分割

### 統合不始末防止（Phase 4統合、2025-12-27追加）

振動診断プロトタイプの失敗事例（11 sins）から抽出した対策を統合しました。

- **範囲逸脱**: 最小限実装 + 単純構造の原則
  - **対策**: `docs/rules/task-integrity.md` - タスク範囲遵守（FP-6, FP-7）
- **説明過多**: 実装70% + 説明30%の比率維持
- **虚偽報告**: 技術・表示の両面検証必須
  - **対策**: `docs/rules/deployment.md` - デプロイ後検証（FP-9）
- **テスト改ざん**: テストを弱めずに実装を修正
  - **対策**: `docs/rules/test.md` - TDD鉄則、テスト品質（FP-1）
- **実装ショートカット**: エラーハンドリング・バリデーション省略禁止
  - **対策**: `docs/rules/implementation.md` - 段階的実装、文脈適合（FP-2, FP-4）
- **推測による実装**: コードを読まずに「多分こう」で進めない
  - **対策**: `docs/rules/evidence-based-thinking.md` - 証拠ベース思考（FP-8）

**3層防御システム**:
```
Layer 1: Rules（弱）← docs/rules/
  - 基本方針の提示

Layer 2: Skills（中）← .claude/skills/（Phase 4 Step 3で追加予定）
  - コンテキスト起動、より強い誘導

Layer 3: Hooks（強）← .claude/hooks/（Phase 4 Step 4で追加予定）
  - 実行前/後ブロック、最も強力な防御
```

## 2. 送信前必須チェック（30秒）

### レベル1: 基本安全確認
```
□ 技術的事実の確認済み
□ バッククォート競合なし
□ 複雑な内容 → ファイル分離化
```

### レベル2: 品質判定
```
□ 技術内容複雑 OR マークダウン複雑 → 分割必須
□ 10行超のコード → 別ファイル保存必須
□ ファイル設定の確認（適切な拡張子、パス指定）
```

### レベル3: テスト・検証確認
```
□ スクリプト作成 → テスト実行済み
□ 仕様項目 ↔ テスト手段の対応明確
□ 全テストパス → 完了宣言可能
```
**詳細**: `test-process-requirements.md` を参照

## 3. 実践パターン

### パターンA: 技術仕様の安全記述
```
## [技術名] 実装ガイド

### 技術要件
- 機能: [具体的要件]
- 制約: [制約条件]

### 実装
[シンプルな実装は別ファイルで提供]
ファイル: src/implementation.py
```

### パターンB: 複雑内容の段階分割
```
## [複雑内容] 段階実装

### Phase 1: 基本構造
[ファイル分離: src/phase1-basic.py]

### Phase 2: 機能拡張
[ファイル分離: src/phase2-advanced.py]
```

## 4. 緊急時対応

### 崩壊発生時
1. 即座中断 → 問題箇所特定
2. ファイル分離化 → 安全な形で再提供
3. 再発防止 → チェックリスト適用

---

## 5. 参照

- `test-process-requirements.md` - テストプロセス要件
- `universal-instruction-quality-rules.md` - 品質ルール

---

**核心原則**: 迷ったら「分割」「ファイル分離」を選択
