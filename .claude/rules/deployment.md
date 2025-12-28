# デプロイ・検証ルール

**対策対象**: FP-9（デプロイ検証不足）
**優先度**: High
**出典**: vibration-diagnosis-prototype失敗事例、WORK_PROCESS_PROTOCOLS Protocol 6

## やってはいけないこと

### 1. デプロイ後の検証不足

**絶対禁止**:
- デプロイコマンド実行後、結果を確認せずに完了報告
- エラーメッセージを無視して「デプロイ完了」と報告
- デプロイ先の動作確認をせずに完了
- ログ・エラー出力を確認せずに次のタスクへ
- CI/CDのステータス確認を省略

**具体例（vibration-diagnosis-prototype Sin 9）**:
```bash
# ❌ 悪い例：デプロイ後の確認なし
$ npm run deploy
# （出力を見ずに）「デプロイが完了しました」と報告

# ✅ 正しい例：デプロイ後の確認実施
$ npm run deploy
Deploying to production...
✓ Build successful
✓ Files uploaded
✓ Cache cleared
Deployment complete!

$ curl https://example.com/health
{"status": "ok", "version": "1.2.3"}

# 確認後に報告：「デプロイ完了。ヘルスチェックでversion 1.2.3を確認しました」
```

### 2. 中間ステータスでの完了報告

**禁止**:
- ビルドは成功したがデプロイ前に「完了」と報告
- デプロイは成功したが動作確認前に「完了」と報告
- CI/CDが実行中なのに「完了」と報告
- エラーが発生しているのに「ほぼ完了」と報告

### 3. エラーの隠蔽

**禁止**:
- エラーログを無視する
- 警告を「些細なこと」として無視する
- デプロイ失敗を「一時的な問題」として放置する
- ロールバックせずに次の修正を試みる

## やるべきこと

### 1. デプロイ前チェック（Pre-Deployment Checklist）

**必須確認事項**:
- [ ] すべてのテストがパス（`npm test`, `pytest`等）
- [ ] ビルドが成功（`npm run build`, `cargo build`等）
- [ ] Lintエラーなし（`npm run lint`, `flake8`等）
- [ ] 型チェック成功（TypeScript, mypy等）
- [ ] 依存関係が最新（`npm audit`, `pip check`等）

**例**:
```bash
# Pre-deployment verification
npm test          && echo "✓ Tests passed" ||      exit 1
npm run lint      && echo "✓ Lint passed" ||       exit 1
npm run typecheck && echo "✓ Type check passed" || exit 1
npm run build     && echo "✓ Build succeeded" ||   exit 1

# デプロイ実行
npm run deploy
```

### 2. デプロイ中の監視

**監視項目**:
- [ ] デプロイスクリプトの出力を読む
- [ ] エラーメッセージの有無を確認
- [ ] 警告メッセージの有無を確認
- [ ] デプロイ進捗の確認（progress bar, ログ）
- [ ] タイムアウトしていないか確認

**例**:
```bash
$ npm run deploy

# 出力を注意深く読む
Building...
✓ Transpiled 245 files
✓ Bundled 12 chunks
✓ Minified assets
Uploading to S3...
✓ Uploaded 156 files (12.3 MB)
Invalidating CloudFront cache...
✓ Cache invalidated
Deployment successful!

# ✅ すべてのステップが ✓ であることを確認
```

### 3. デプロイ後検証（Post-Deployment Verification）

**必須検証項目**:

#### a. ヘルスチェック
```bash
# API health check
$ curl https://api.example.com/health
{"status": "ok", "version": "1.2.3", "timestamp": "2025-12-27T08:00:00Z"}

# Web health check
$ curl -I https://example.com
HTTP/2 200
content-type: text/html
```

#### b. 主要機能の動作確認
```bash
# 認証機能
$ curl -X POST https://api.example.com/auth/login \
  -d '{"username":"test","password":"test"}'
{"token": "eyJ..."}

# データ取得
$ curl -H "Authorization: Bearer eyJ..." \
  https://api.example.com/api/users/me
{"id": "user-123", "name": "Test User"}
```

#### c. ログ確認
```bash
# アプリケーションログ
$ kubectl logs -n production deployment/app --tail=50

# エラーログのチェック
$ kubectl logs -n production deployment/app | grep -i error
# （エラーがないことを確認）
```

#### d. メトリクス確認
```bash
# CPU/メモリ使用率
$ kubectl top pods -n production

# レスポンスタイム
$ curl -w "@curl-format.txt" -o /dev/null -s https://example.com
time_total: 0.245s

# エラーレート（過去5分）
$ kubectl logs -n production deployment/app --since=5m | grep -c ERROR
0
```

### 4. デプロイ完了の定義（Definition of Done）

**完了基準**:
- [ ] デプロイスクリプトが正常終了（exit code 0）
- [ ] ヘルスチェックが成功
- [ ] 主要機能が動作確認済み
- [ ] エラーログがない（または許容範囲内）
- [ ] パフォーマンス低下がない
- [ ] ロールバック手順を確認済み

**完了報告の例**:
```markdown
✅ デプロイ完了

**確認済み項目**:
- デプロイスクリプト: 正常終了
- ヘルスチェック: OK (version 1.2.3)
- ログイン機能: 正常動作
- ユーザーデータ取得: 正常動作
- エラーログ: 0件
- レスポンスタイム: 245ms（前回: 250ms）

**デプロイ内容**:
- ユーザー認証機能の改善
- API応答速度の最適化
```

## 例外処理

### 例外が許される場合

1. **Staging環境へのデプロイ**
   - **条件**: Production以外の環境
   - **手順**:
     1. 最小限の確認（ヘルスチェックのみ等）
     2. 「Stagingへのデプロイ完了」と明記

2. **ホットフィックス**
   - **条件**: 緊急の本番障害対応
   - **手順**:
     1. 最小限の修正
     2. 迅速なデプロイ
     3. デプロイ後に詳細な検証（事後検証）

## 防御層（Multi-layer Defense）

### Layer 1: Rules（本ドキュメント）
- **効果**: 弱（LLMが無視する可能性あり）
- **役割**: 基本方針の提示

### Layer 2: Skills
- **効果**: 中（コンテキストに応じて起動）
- **スキル**: `deployment-verifier`
- **機能**: デプロイ後検証の誘導、チェックリスト提示

### Layer 3: Hooks
- **効果**: 強（実行後に検証強制）
- **フック**: `post_deploy_verification.sh`（PostToolUse: Bash）
- **機能**:
  - デプロイコマンド検出（`deploy`, `publish`, `release`）
  - 検証プロンプト表示
  - 検証完了までブロック

**Hookの例**:
```bash
#!/bin/bash
# .claude/hooks/post_deploy_verification.sh

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // empty')

# デプロイコマンドを検出
if echo "$COMMAND" | grep -E "(deploy|publish|release)" > /dev/null; then
  echo "⚠️  デプロイコマンドを検出しました" >&2
  echo "" >&2
  echo "以下を確認してください:" >&2
  echo "  1. デプロイスクリプトが正常終了したか" >&2
  echo "  2. ヘルスチェックが成功したか" >&2
  echo "  3. 主要機能が動作するか" >&2
  echo "  4. エラーログがないか" >&2
  echo "" >&2
  echo "確認後、デプロイ完了報告をしてください" >&2
fi

echo "$INPUT"
```

## ベストプラクティス

### 1. Staged Verification（段階的検証）

**Level 1: Local**
- ローカル環境でテスト
- ビルド確認

**Level 2: CI/CD**
- 自動テスト
- 自動ビルド
- 自動デプロイ（Staging）

**Level 3: Staging**
- 本番類似環境での確認
- 統合テスト
- パフォーマンステスト

**Level 4: Production**
- カナリアリリース（一部ユーザーのみ）
- モニタリング
- 段階的ロールアウト

### 2. Automated Verification（自動検証）

**CI/CDパイプライン例**:
```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
      - name: Deploy to production
        run: npm run deploy
      - name: Health check
        run: |
          sleep 10  # デプロイ完了待機
          curl -f https://example.com/health || exit 1
      - name: Smoke test
        run: npm run test:smoke
```

### 3. Rollback Plan（ロールバック計画）

**事前準備**:
- ロールバック手順の文書化
- ロールバックスクリプトのテスト
- 前バージョンのバックアップ保持

**ロールバック判断基準**:
- エラーレートが5%以上
- レスポンスタイムが2倍以上
- ヘルスチェック失敗
- ユーザーからの障害報告

## 関連ドキュメント

- `test.md`: テスト品質ルール
- `implementation.md`: 実装品質ルール
- `verification-enforcer` (Skill): 検証ステップ強制
- `post_deploy_verification.sh` (Hook): デプロイ後検証

## 参考リンク

- [vibration-diagnosis-prototype WORK_PROCESS_PROTOCOLS](vibration-diagnosis-prototype/docs/WORK_PROCESS_PROTOCOLS_20251227.md): Protocol 6
- [vibration-diagnosis-prototype CRITICAL_FAILURE_REPORT](vibration-diagnosis-prototype/docs/CRITICAL_FAILURE_REPORT_20251226.md): Sin 9
- [Google SRE Book - Deployment](https://sre.google/sre-book/release-engineering/)
- [The Twelve-Factor App - Config](https://12factor.net/)

---

**最終更新**: 2025-12-27
**バージョン**: 1.0
**ステータス**: Phase 4統合版
