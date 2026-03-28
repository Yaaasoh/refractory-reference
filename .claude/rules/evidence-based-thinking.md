# 証拠ベース思考ルール

**対策対象**: FP-8（推測による実装）
**優先度**: High
**適用範囲**: すべてのパッケージ（technical, prompt-creation）
**出典**: WORK_PROCESS_PROTOCOLS Protocol 1, vibration-diagnosis-prototype失敗事例

## 概要

このルールは、「推測」ではなく「証拠」に基づいて作業を進めることを徹底します。

**証拠の定義**:
- 実際に確認したドキュメント
- 実際に読んだコード
- 実際に実行した結果
- 実際に受け取ったエラーメッセージ

**推測の定義**:
- 「〜だろう」「〜はず」に基づく判断
- ドキュメントを読まずに判断
- コードを読まずに判断
- エラーメッセージを読まずに判断

## やってはいけないこと

### 1. 推測による作業

**絶対禁止**:
- コードを読まずに「〜だろう」で実装を進める
- ドキュメントを確認せずに仕様を推測する
- テストを書かずに「動くはず」で完了報告
- エラーメッセージを読まずに「よくあるエラー」と決めつける
- APIレスポンスを確認せずに処理を書く

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

### 2. ドキュメントを読まない

**禁止**:
- README.mdを読まずに開発開始
- API仕様書を読まずに連携実装
- 公式ドキュメントを読まずに問題解決
- CLAUDE.mdを読まずにプロジェクトルール無視
- CONTRIBUTING.mdを読まずにPR作成

### 3. エラーメッセージを無視

**禁止**:
- エラーメッセージを読まずに「いつものエラー」と決めつける
- スタックトレースを確認せずに対処する
- ログを確認せずにデバッグする
- エラーコードを調べずに対処する

## やるべきこと

### 1. Read First, Code Later

**WORK_PROCESS_PROTOCOLS Protocol 1**:
> 推測ではなく、実際のコードを読んで確認する

**3ステップアプローチ**:

#### Step 1: Read（読む）

**コードを読む（Read the Code）**:

a. 関数の仕様確認
```bash
# 関数定義を確認
$ grep -A 20 "def get_user_data" src/users.py

# または Read ツールを使用
# Read: src/users.py (該当行)
```

b. 戻り値の型確認
```bash
# 型ヒントを確認
$ grep "def get_user_data" src/users.py
def get_user_data(user_id: str) -> User:
                                   ^^^^
# User オブジェクトを返すことが確定
```

c. 実際の使用例を確認
```bash
# 既存の呼び出し元を探す
$ grep -B 2 -A 5 "get_user_data(" src/**/*.py

# 結果例:
# src/auth.py:
# user = get_user_data(user_id)
# if user.is_active:  # ← .is_active プロパティを使用
#     ...
```

**ドキュメントを読む（Read the Docs）**:

必読ドキュメント:
- [ ] `README.md`: プロジェクト概要、セットアップ手順
- [ ] `CLAUDE.md`: プロジェクトルール、禁止事項
- [ ] `CONTRIBUTING.md`: コントリビューションガイドライン
- [ ] `API.md` / `docs/api/`: API仕様
- [ ] `ARCHITECTURE.md`: アーキテクチャ設計

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

#### Step 2: Verify（確認する）
```bash
# 実際に動かして確認
$ python -c "from src.users import get_user; print(type(get_user(1)))"
<class 'User'>  # Userオブジェクトを返すことを確認

# APIレスポンスを確認
$ curl https://api.example.com/users/1
{"id": 1, "name": "Test", "email": "test@example.com"}
```

#### Step 3: Implement（実装する）
```python
# 確認した証拠に基づいて実装
user = get_user(user_id)  # Userオブジェクトを返すことを確認済み
name = user.name           # .name属性でアクセス可能を確認済み
```

### 2. エラーメッセージを読む（Read the Error）

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

#### Step 2: スタックトレースを追跡
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

### 3. 証拠収集のチェックリスト

**作業前**:
- [ ] 関連するコードを読んだか？
- [ ] 仕様書・ドキュメントを読んだか？
- [ ] 既存の使用例を確認したか？
- [ ] 不明点をユーザーに質問したか？（AskUserQuestion）

**作業中**:
- [ ] 推測ではなく、確認した事実に基づいているか？
- [ ] エラーが出たら、メッセージ全文を読んだか？
- [ ] ログ・デバッグ出力を確認したか？

**作業後**:
- [ ] 実際に動作を確認したか？
- [ ] テストで検証したか？
- [ ] ドキュメントと実装が一致しているか？

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

## 証拠の記録

### 証拠を残す理由

**透明性**:
- なぜこの実装にしたのか、後から追跡可能

**再現性**:
- 同じ問題が起きた時、すぐに原因特定可能

**学習**:
- チーム全体で知見を共有可能

### 記録の例

```markdown
## 実装記録: get_user関数の戻り値

### 調査日: 2025-12-27

### 証拠1: コード確認
```bash
$ grep -A 10 "def get_user" src/users.py
def get_user(user_id: str) -> User:
    """ユーザー情報を取得"""
    return User.query.get(user_id)
```

### 証拠2: 既存使用例
```bash
$ grep "get_user(" src/**/*.py
src/auth.py: user = get_user(user_id)
src/auth.py: if user.is_active:  # .is_active 属性を使用
```

### 証拠3: 型ヒント
- 戻り値: `User` オブジェクト
- `User` クラスは `src/models/user.py` で定義

### 結論
- `get_user` は `User` オブジェクトを返す
- `user.name`, `user.email`, `user.is_active` 等の属性でアクセス可能
```

---

## Plan Mode使用時の証拠収集

Plan Mode使用時は `plan-mode.md` も参照。計画フェーズでの調査義務はPlan Modeに特化したルールで定義。

## Skill使用時の証拠収集

### 原則: 具体→抽象の順序

**禁止**: skillドキュメント（抽象）のみ確認して作業開始

**理由**:
- 正しいファイルパターン・構成を把握できない
- 暗黙のルール（分割維持、統合禁止等）を見落とす
- 過去の成果物の品質レベルを把握できない

### 必須手順（Phase 0）

skill使用前に以下を実施：

1. **具体的成果物の確認**: 過去の実際のファイルを最低1件確認
2. **パターンの把握**: ファイル構成、命名規則、分割基準
3. **ドキュメントの確認**: skillドキュメント、進捗報告書
4. **作業計画の作成**: 把握したパターンに基づいて計画

### チェックリスト

**作業開始前**:
- [ ] 過去の成果物を確認したか？（最低1件）
- [ ] ファイルパターンを把握したか？
- [ ] 暗黙のルール（分割維持、統合禁止等）を確認したか？
- [ ] skillドキュメントを確認したか？

### 過去のインシデント

**INC-013（2026-01-07）**:
- skillドキュメントのみ確認して「準備完了」と報告
- meeting_transcriptsフォルダと分割パターンを見落とした
- ファイル分割が抜けた不完全な作業計画

**教訓**: 抽象（ドキュメント）の前に、具体（実際のファイル）を確認する

---

## 調査作業での証拠保全

### WebSearch結果の100%保存義務

```
WebSearch/WebFetch実行回数 = 保存ファイル数
```

**絶対禁止**: WebSearch結果を捨てる（保存せずに次の作業に進む）

調査で得た情報は `sources/YYYYMMDD_topic_sources.txt` 等に必ず保存する。
WebSearch結果をコンテキスト内で消費するだけでファイルに残さないのは証拠の破棄と同等。

### コマンド・ツールの存在確認義務

**禁止**: コマンドやオプションの存在を推測で提示する

**必須手順**:
1. `where <command>` / `ls <path>` でコマンドの存在を確認する
2. `<command> --help` でオプションを確認する
3. 確認結果に基づいて提示する

**過去のインシデント（INC-RUNNER-20260310）**:
コマンドの存在・オプションを確認せず推測で6回連続失敗。
`where`/`--help`で1回確認すれば防げた。

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**:
  - `root-cause-analyzer`（technical-projects-cli）
  - `prompt-purpose-validator`（prompt-creation-projects-cli）
- **機能**: 証拠収集の誘導、根本原因追究

### Layer 3: Hooks
- **効果**: （証拠ベース思考はHookでの強制が困難）
- **代替**: Skill自動起動で証拠収集を促す

## ベストプラクティス

### 1. Documentation First

**原則**:
> コードを書く前に、ドキュメントを読む

**チェックポイント**:
- [ ] README.md を読んだ
- [ ] CLAUDE.md を読んだ
- [ ] API仕様書を読んだ
- [ ] 関連するIssue/PRを確認した

### 2. Code as Documentation

**原則**:
> コードは嘘をつかない、コメントは嘘をつく

**実践**:
```python
# ❌ 悪い例：コメントを信じる
# この関数はdictを返す
user = get_user(user_id)

# ✅ 良い例：コードを読む
# $ grep "def get_user" src/users.py
# → def get_user(user_id: str) -> User:
user = get_user(user_id)
```

### 3. Trust but Verify

**原則**:
> ドキュメントを信頼するが、コードで検証する

**実践**:
```markdown
1. ドキュメント: "get_user はUserオブジェクトを返す"
2. 信頼する
3. しかし検証: `grep "def get_user" src/users.py`
4. 確認: 実際にUserオブジェクトを返す
5. 実装: 検証した事実に基づいて実装
```

### 4. Error Messages are Your Friend

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

### パッケージ固有ルール
- `technical-projects-cli/docs/rules/implementation.md` - 実装品質
- `prompt-creation-projects-cli/docs/rules/purpose-first.md` - 目的優先

### 共有ルール
- `shared/rules/anti-tampering-rules.md` - 改ざん防止
- `shared/rules/hook-response-protocol.md` - Hook対応

## 参考リンク

- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 1（Evidence-Based Thinking）
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 8
- [The Pragmatic Programmer - Debug](https://pragprog.com/): デバッグ手法
- [Google Engineering Practices - Code Review](https://google.github.io/eng-practices/review/): コードレビューでの証拠確認

---

**最終更新**: 2026-03-17
**バージョン**: 2.1（H1/H6教訓追加）
**ステータス**: Phase 4統合版
**適用**: すべてのパッケージ
