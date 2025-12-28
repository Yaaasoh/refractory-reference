# 証拠ベース思考ルール（汎用版）

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
- ドキュメントを読まずに「多分こうだろう」で進める
- コードを読まずに「こう動くはず」で実装する
- エラーメッセージを読まずに「よくあるエラー」と決めつける
- APIレスポンスを確認せずに処理を書く

**具体例**:
```python
# ❌ 悪い例：推測で実装
# 推測: "get_user関数は多分dictを返すだろう"
user = get_user(user_id)
name = user['name']  # KeyError発生の可能性

# ✅ 正しい例：コードを読んで確認
# $ grep -A 5 "def get_user" src/users.py
# 確認結果: Userオブジェクトを返す

user = get_user(user_id)
name = user.name  # 実際の仕様に基づいて実装
```

### 2. ドキュメントを読まない

**禁止**:
- README.mdを読まずに開発開始
- API仕様書を読まずに連携実装
- 公式ドキュメントを読まずに問題解決
- CLAUDE.mdを読まずにプロジェクトルール無視

### 3. エラーメッセージを無視

**禁止**:
- エラーメッセージを読まずに「いつものエラー」と決めつける
- スタックトレースを確認せずに対処する
- ログを確認せずにデバッグする

## やるべきこと

### 1. Read First, Code Later

**WORK_PROCESS_PROTOCOLS Protocol 1**:
> 推測ではなく、実際のコードを読んで確認する

**3ステップアプローチ**:

#### Step 1: Read（読む）
```bash
# ドキュメントを読む
$ cat README.md
$ cat API.md
$ cat CLAUDE.md

# コードを読む（Readツール、またはgrep）
$ grep -A 10 "def function_name" src/*.py
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

### 2. エラーメッセージを読む

**正しい手順**:

#### Step 1: エラーメッセージ全文を読む
```python
Traceback (most recent call last):
  File "app.py", line 42, in process_data
    result = data['name']
KeyError: 'name'

# ← 全文を読む：dictにnameキーが存在しない
```

#### Step 2: スタックトレースを追跡
```python
# エントリポイントから問題箇所まで追跡
File "app.py", line 10, in main
  result = process_user(user_id)
File "app.py", line 25, in process_user
  data = fetch_data(user_id)
File "api.py", line 50, in fetch_data
  return response.json()  # ← 問題箇所
KeyError: 'name'
```

#### Step 3: 原因を特定
```bash
# APIレスポンスを実際に確認
$ curl https://api.example.com/users/123
{"id": 123, "username": "test"}  # 'name'ではなく'username'

# 修正
- name = data['name']
+ name = data['username']
```

### 3. 証拠収集のチェックリスト

**作業前**:
- [ ] 関連ドキュメントを読んだか？
- [ ] 関連コードを読んだか？
- [ ] 既存の使用例を確認したか？
- [ ] 不明点をユーザーに質問したか？

**作業中**:
- [ ] 推測ではなく、確認した事実に基づいているか？
- [ ] エラーが出たら、メッセージ全文を読んだか？
- [ ] ログ・デバッグ出力を確認したか？

**作業後**:
- [ ] 実際に動作を確認したか？
- [ ] テストで検証したか？
- [ ] ドキュメントと実装が一致しているか？

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

## 関連ドキュメント

### パッケージ固有ルール
- `technical-projects-cli/docs/rules/evidence-based-thinking.md` - 詳細版（技術系）
- `technical-projects-cli/docs/rules/implementation.md` - 実装品質
- `prompt-creation-projects-cli/docs/rules/purpose-first.md` - 目的優先

### 共有ルール
- `shared/rules/anti-tampering-rules.md` - 改ざん防止
- `shared/rules/hook-response-protocol.md` - Hook対応

## 参考リンク

- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 1
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 8
- [The Pragmatic Programmer](https://pragprog.com/): 実用的プログラミング

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版（汎用）
**適用**: すべてのパッケージ

**Note**: 技術系プロジェクトでより詳細なガイドが必要な場合は、`technical-projects-cli/docs/rules/evidence-based-thinking.md`（詳細版）を参照してください。
