# 証拠ベース思考ルール

**対策対象**: FP-8（推測による実装）
**優先度**: High
**出典**: WORK_PROCESS_PROTOCOLS Protocol 1, vibration-diagnosis-prototype失敗事例

## やってはいけないこと

### 1. 推測による実装

**絶対禁止**:
- コードを読まずに「〜だろう」で実装を進める
- ドキュメントを確認せずに仕様を推測する
- テストを書かずに「動くはず」で完了報告
- APIレスポンスを確認せずに処理を書く
- エラーメッセージを読まずに原因を推測する

**具体例（vibration-diagnosis-prototype Sin 8）**:
```python
# ❌ 悪い例：推測で実装
# 推測: "この関数は多分 dict を返すだろう"
result = get_user_data(user_id)
name = result['name']  # 推測で実装 → KeyError発生

# ✅ 正しい例：コードを読んで確認
# $ grep -A 10 "def get_user_data" src/users.py
# 確認結果: User オブジェクトを返す

result = get_user_data(user_id)
name = result.name  # 実際の仕様に基づいて実装
```

### 2. ドキュメントを読まずに実装

**禁止**:
- README.mdを読まずに開発開始
- API仕様書を読まずに連携実装
- CLAUDE.mdを読まずにプロジェクトルール無視
- CONTRIBUTING.mdを読まずにPR作成

### 3. エラーメッセージを無視

**禁止**:
- エラーメッセージを読まずに「よくあるエラー」と決めつける
- スタックトレースを確認せずに原因を推測する
- ログを確認せずにデバッグする
- エラーコードを調べずに対処する

## やるべきこと

### 1. コードを読む（Read the Code）

**WORK_PROCESS_PROTOCOLS Protocol 1**:
> 推測ではなく、実際のコードを読んで確認する

**実践手順**:

#### a. 関数の仕様確認
```bash
# 関数定義を確認
$ grep -A 20 "def get_user_data" src/users.py

# または Read ツールを使用
# Read: src/users.py (該当行)
```

#### b. 戻り値の型確認
```bash
# 型ヒントを確認
$ grep "def get_user_data" src/users.py
def get_user_data(user_id: str) -> User:
                                   ^^^^
# User オブジェクトを返すことが確定
```

#### c. 実際の使用例を確認
```bash
# 既存の呼び出し元を探す
$ grep -B 2 -A 5 "get_user_data(" src/**/*.py

# 結果例:
# src/auth.py:
# user = get_user_data(user_id)
# if user.is_active:  # ← .is_active プロパティを使用
#     ...
```

### 2. ドキュメントを読む（Read the Docs）

**必読ドキュメント**:
- [ ] `README.md`: プロジェクト概要、セットアップ手順
- [ ] `CLAUDE.md`: プロジェクトルール、禁止事項
- [ ] `CONTRIBUTING.md`: コントリビューションガイドライン
- [ ] `API.md` / `docs/api/`: API仕様
- [ ] `ARCHITECTURE.md`: アーキテクチャ設計

**読み方の例**:
```bash
# README.mdを最初に読む
$ cat README.md | head -100

# プロジェクト固有ルールを確認
$ cat CLAUDE.md

# API仕様を確認
$ ls docs/api/
users.md  auth.md  data.md

$ cat docs/api/users.md
```

### 3. エラーメッセージを読む（Read the Error）

**エラー対応の正しい手順**:

#### Step 1: エラーメッセージ全文を読む
```python
# ❌ 悪い例：エラーの一部だけ見る
# Traceback (most recent call last):
#   File "app.py", line 42, in process_data
#     result = data['name']
# KeyError: 'name'  ← ここだけ見て「dictにnameがない」と判断

# ✅ 正しい例：エラーメッセージ全文を読む
# Traceback (most recent call last):
#   File "app.py", line 42, in process_data
#     result = data['name']
# KeyError: 'name'
#
# During handling of the above exception, another exception occurred:
# ...
# ValueError: Invalid data format: expected dict, got list
                                        ^^^^        ^^^^
# ← 実際の問題は「dictではなくlistを受け取っている」
```

#### Step 2: スタックトレースを確認
```python
# スタックトレースから呼び出し経路を追跡
Traceback (most recent call last):
  File "app.py", line 10, in main
    result = process_user(user_id)  ← エントリポイント
  File "app.py", line 25, in process_user
    data = fetch_data(user_id)      ← データ取得
  File "api.py", line 50, in fetch_data
    return response.json()          ← 問題箇所
KeyError: 'name'

# 問題箇所: api.py:50 の response.json() が期待した形式と異なる
```

#### Step 3: 原因を特定
```bash
# APIレスポンスを確認
$ curl https://api.example.com/users/user-123
[{"id": "user-123", "name": "Test"}]  # list を返している！
                                      # （期待: dict）

# コードを修正
- data = response.json()        # list が返る
+ data = response.json()[0]     # list の最初の要素を取得
```

### 4. 証拠収集のパターン

#### パターン1: 関数の仕様確認
```markdown
**目的**: `calculate_total` 関数の戻り値の型を確認

**証拠収集**:
1. Read ツールで関数定義を確認
   → `def calculate_total(items: List[Item]) -> Decimal:`
2. 既存の使用例を Grep で検索
   → `total = calculate_total(items)` （10箇所で使用）
3. テストコードを Read で確認
   → `assert calculate_total([]) == Decimal('0.00')`

**結論**: Decimal型を返す、空リストの場合は Decimal('0.00')
```

#### パターン2: API仕様確認
```markdown
**目的**: `/api/users/{id}` エンドポイントのレスポンス形式確認

**証拠収集**:
1. API仕様書を Read
   → `docs/api/users.md` に記載あり
2. 実際のレスポンスを Bash (curl) で確認
   → `{"id": "...", "name": "...", "email": "..."}`
3. 既存の呼び出し元を Grep で検索
   → `user.email` でアクセスしている箇所を発見

**結論**: JSON object を返す、emailフィールドあり
```

#### パターン3: エラー原因の特定
```markdown
**目的**: `TypeError: 'NoneType' object is not subscriptable` の原因特定

**証拠収集**:
1. スタックトレースを読む
   → `data[0]` でエラー、data が None
2. data の取得元を Read で確認
   → `data = fetch_data(url)` が None を返している
3. fetch_data の実装を Read で確認
   → エラー時に None を返す仕様（要改善）

**結論**: fetch_data がエラー時に None を返す、エラーハンドリングが必要
```

## 証拠ベース実装のチェックリスト

**実装前**:
- [ ] 関連するコードを読んだか？
- [ ] 仕様書・ドキュメントを読んだか？
- [ ] 既存の使用例を確認したか？
- [ ] 不明点をユーザーに質問したか？（AskUserQuestion）

**実装中**:
- [ ] 推測ではなく、確認した仕様に基づいて実装しているか？
- [ ] エラーが出たら、メッセージ全文を読んだか？
- [ ] ログ・デバッグ出力を確認したか？

**実装後**:
- [ ] テストで実際の動作を確認したか？
- [ ] エッジケース・エラーケースを確認したか？
- [ ] ドキュメントと実装が一致しているか？

## 例外処理

### 例外が許される場合

1. **プロトタイピング**
   - **条件**: ユーザーが「とりあえず動くもの」を明示的に要求
   - **手順**:
     1. 「プロトタイプ」であることを明記
     2. 推測箇所を TODO コメントで記載
     3. 本実装時に証拠ベースで再実装

2. **時間制約のある緊急対応**
   - **条件**: 本番障害等の緊急対応
   - **手順**:
     1. 最小限の確認で暫定対応
     2. 事後に詳細な証拠収集と恒久対策

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**: `root-cause-analyzer`
- **機能**:
  - エラー発生時に証拠収集を誘導
  - スタックトレース分析
  - 根本原因の追究

### Layer 3: Hooks
- **効果**: 強（実装前に確認促進）
- **フック**: （証拠ベース思考はHookでの強制が困難）
- **代替**: Skill自動起動で実装前に証拠収集を促す

## ベストプラクティス

### 1. "Read First, Code Later"

**原則**:
> コードを書く前に、必ず関連するコード・ドキュメントを読む

**実践**:
```markdown
# タスク: ユーザー認証機能の追加

## Step 1: Read (証拠収集)
- [x] 既存の認証機能を Read で確認
- [x] 認証ライブラリのドキュメント確認
- [x] 既存のテストコードを確認

## Step 2: Plan (計画)
- [ ] 既存パターンに従った実装計画
- [ ] テスト戦略

## Step 3: Code (実装)
- [ ] 証拠に基づいた実装
```

### 2. "Trust but Verify"

**原則**:
> ドキュメントを信頼するが、コードで検証する

**実践**:
```bash
# ドキュメント: "この関数は User オブジェクトを返す"
# → 信頼する、しかし検証する

$ grep -A 10 "def get_user" src/users.py
# → 実際の実装を確認

$ grep "get_user(" src/**/*.py
# → 実際の使用例を確認

# 検証結果: ドキュメント通り User オブジェクトを返す
```

### 3. "Error Messages are Your Friend"

**原則**:
> エラーメッセージは敵ではなく、問題解決のヒント

**実践**:
```python
# エラーメッセージを丁寧に読む
TypeError: unsupported operand type(s) for +: 'int' and 'str'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^   ^^^     ^^^
           演算子 + が使えない                int型    str型

# エラーメッセージから原因を特定
# → int と str を + しようとしている
# → どちらかを型変換する必要がある
```

## 関連ドキュメント

- `implementation.md`: 実装品質ルール
- `test.md`: テスト品質ルール
- `root-cause-analyzer` (Skill): 根本原因分析
- `phase3-use-cases-tips/step3.5-failure-case-analysis.md`: FP-8詳細

## 参考リンク

- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 1（Evidence-Based Thinking）
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 8
- [The Pragmatic Programmer - Debug](https://pragprog.com/): デバッグ手法
- [Google Engineering Practices - Code Review](https://google.github.io/eng-practices/review/): コードレビューでの証拠確認

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版
