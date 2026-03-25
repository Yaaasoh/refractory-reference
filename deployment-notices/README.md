# 導入案内ドキュメント一覧

このディレクトリには、既存リポジトリへの prompt-patterns 改良版導入案内が含まれています。

---

## 📚 ドキュメント構成

### 1. 包括的ガイド

**DEPLOYMENT_GUIDE.md** (親ディレクトリ)
- 全リポジトリ共通の詳細ガイド
- 所要時間: 初回は30分、2回目以降は10分
- 対象: すべてのリポジトリ

### 2. リポジトリ別簡潔案内（このディレクトリ）

| ファイル | 対象リポジトリ | 所要時間 |
|---------|--------------|---------|
| **NOTICE_FOR_TECH_ARTICLES.md** | tech-articles | 10分 |
| **NOTICE_FOR_VIBRATION_DIAGNOSIS.md** | vibration-diagnosis-prototype | 10分 |
| **NOTICE_FOR_TECH_RESEARCH_PORTFOLIO.md** | tech-research-portfolio | 15分 |
| **NOTICE_FOR_JSBSIM_FLIGHTGEAR_GUIDE.md** | jsbsim-flightgear-guide | 10分 |
| **NOTICE_FOR_PST_DEV_DOCS.md** | pst_dev_docs | 10分 |
| **NOTICE_FOR_ACCOUNT_MANAGEMENT.md** | account-management | 10分 |
| **NOTICE_FOR_FLYING_ROBOT_RULE_CODING_PRIVATE.md** | flying-robot-rule-coding-private | 10分 |
| **NOTICE_FOR_FLYING_ROBOT_CONTEST_RULES_PUBLIC.md** | flying-robot-contest-rules-public | 10分 |
| **NOTICE_FOR_JSBSIM_XML_GENERATOR.md** | jsbsim-xml-generator | 10分 |
| **NOTICE_FOR_OCR_APP.md** | ocr-app | 15分 |

---

## アップデート通知

リポジトリ横断の更新情報。各リポジトリで作業する際に確認してください。

| ファイル | 日付 | 内容 |
|---------|------|------|
| **UPDATE_20260306_SESSION_STABILITY.md** | 2026-03-06 | セッション安定化・/recover導入・ccusage・ベストプラクティス |
| **UPDATE_20260307_WEB_RESEARCHER_PERMISSION.md** | 2026-03-07 | web-researcher サブエージェント permissionMode修正（Critical） |
| **UPDATE_20260307_DIAGRAM_GENERATION_GUIDELINES.md** | 2026-03-07 | 図生成の行動指針（rules + skills）導入 |
| **UPDATE_20260308_OCR_WORKFLOW_TOOLS.md** | 2026-03-08 | OCRワークフローツール追加（コマンド/スキル/MCP設定） |
| **UPDATE_20260308_OCR_MIGRATION_TECH_ARTICLES.md** | 2026-03-08 | tech-articles OCR移行ガイド（既存14スクリプトとの対応） |
| **UPDATE_20260309_PYTHON_PATH_GUARD.md** | 2026-03-09 | Pythonパスガード導入（素のpython/python3を即ブロック） |
| **UPDATE_20260314_PLAN_MODE_QUALITY.md** | 2026-03-14 | Plan Mode計画品質ルール・リマインダーフック導入 |
| **UPDATE_20260317_LEARNING_MEMO_SEPARATION.md** | 2026-03-17 | CLAUDE.md学習メモ分離手順書・rules/ 3ファイル更新 |
| **UPDATE_20260320_LEARNING_MEMO_PATH_FIX.md** | 2026-03-20 | 学習メモ正本パス明記（全リポジトリ対象） |
| **UPDATE_20260323_LOCAL_LLM_AGENT.md** | 2026-03-23 | ローカルLLM調査エージェント導入（mcp_runner.py） |
| **UPDATE_20260325_LOCAL_LLM_D39.md** | 2026-03-25 | mcp_runner.py D3-9完了 + 新コマンド（/lookup-docs、/troubleshoot） |

---

## クイックスタート

### あなたのリポジトリに合った案内を選択

#### tech-articles を使用している場合
→ **NOTICE_FOR_TECH_ARTICLES.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ WebSearch 100%保存義務の明確化
- ✅ 技術ツールノウハウ集（BibTeX, Quarto, OCR）

#### vibration-diagnosis-prototype を使用している場合
→ **NOTICE_FOR_VIBRATION_DIAGNOSIS.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ テストプロセス要件の明確化（完了の定義）
- ✅ 6フェーズ開発テンプレート

#### tech-research-portfolio を使用している場合
→ **NOTICE_FOR_TECH_RESEARCH_PORTFOLIO.md** を参照

**追加される主要機能**:
- ✅ Claude Code CLI 完全セットアップ
- ✅ 調査ワークフロー標準化
- ✅ 参照テンプレート集

#### jsbsim-flightgear-guide を使用している場合
→ **NOTICE_FOR_JSBSIM_FLIGHTGEAR_GUIDE.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ 技術文書作成向け機能（WebSearch 100%保存義務、引用管理）
- ✅ テストプロセス要件

#### pst_dev_docs を使用している場合
→ **NOTICE_FOR_PST_DEV_DOCS.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ 開発ドキュメント向け機能（6フェーズ開発プロセス）
- ✅ テストプロセス要件

#### account-management を使用している場合
→ **NOTICE_FOR_ACCOUNT_MANAGEMENT.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ 安全性確保（破壊的コマンドブロック、大規模ファイル制限）
- ✅ テストプロセス要件

#### flying-robot-rule-coding-private を使用している場合
→ **NOTICE_FOR_FLYING_ROBOT_RULE_CODING_PRIVATE.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ ルールコーディング向け機能（仕様-テスト対応、6フェーズ開発）
- ✅ テストプロセス要件

#### flying-robot-contest-rules-public を使用している場合
→ **NOTICE_FOR_FLYING_ROBOT_CONTEST_RULES_PUBLIC.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ 公開リポジトリ向け機能（機密情報除外、公開前確認）
- ✅ 技術文書作成ガイドライン

#### jsbsim-xml-generator を使用している場合
→ **NOTICE_FOR_JSBSIM_XML_GENERATOR.md** を参照

**追加される主要機能**:
- ✅ セッション終了時のコミット忘れ防止
- ✅ XML生成向け機能（XML妥当性検証、6フェーズ開発）
- ✅ テストプロセス要件

#### ocr-app を使用している場合
→ **NOTICE_FOR_OCR_APP.md** を参照

**追加される主要機能**:
- ✅ 統合ワークフロー（Phase 0-5: init→preprocess→ocr→postprocess→structure→finalize）
- ✅ マルチエンジンOCR（YomiToku / NDLOCR-Lite / GCP Vision API）
- ✅ tech-articles互換page_mapping.json管理
- ✅ 日本語見出し自動抽出・構造化Markdown生成

#### その他のリポジトリ
→ **DEPLOYMENT_GUIDE.md**（親ディレクトリ）を参照

---

## 📋 導入の3ステップ

すべてのリポジトリで共通の手順:

### Step 1: バックアップ
```bash
cd /path/to/your-repo
cp -r .claude/ .claude.backup-$(date +%Y%m%d)
```

### Step 2: デプロイ
```bash
cd /path/to/prompt-patterns
./scripts/deploy.sh -t /path/to/your-repo
```

### Step 3: 確認
```bash
cd /path/to/your-repo
git status
cat .claude/settings.json | grep -A 5 "Stop"
```

---

## 🎯 今回の改良版で追加される共通機能

### 1. check_uncommitted.sh（Stop Hook）⭐最重要
セッション終了時に未コミットファイルを自動警告

### 2. investigate.md 拡張
WebSearch 100%保存義務の明記

### 3. test-process-requirements.md
完了の定義: `実装 + テスト + パス = 完了`

### 4. 参照テンプレート（3件）
- investigation-workflow-template.md
- 6phase-development-template.md
- technical-tools-reference.md

### 5. デプロイ自動化
scripts/deploy.sh による1コマンド展開

### 6. shared/ 一元管理
共通コンポーネントの集約

---

## 📊 リポジトリタイプ別の比較

### 既存リポジトリ

| 機能 | tech-articles | vibration-diagnosis | tech-research-portfolio |
|------|--------------|--------------------|-----------------------|
| check_uncommitted.sh | ✅ | ✅ | ✅ |
| investigate.md拡張 | ✅ | ✅ | ✅ |
| test-process-requirements | ✅ | ✅ | ✅ |
| technical-tools-reference | ✅ | ✅ | ✅ |
| 6phase-development | ⚠️ | ✅ | ✅ |
| investigation-workflow | ✅ | ⚠️ | ✅ |
| Claude Code完全セット | - | - | ✅ |

### 新規対応リポジトリ

| 機能 | jsbsim-fg-guide | pst_dev_docs | account-mgmt | rule-coding | rules-public | xml-generator |
|------|----------------|--------------|--------------|-------------|--------------|---------------|
| check_uncommitted.sh | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| investigate.md拡張 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| test-process-requirements | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| technical-tools-reference | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ⚠️ |
| 6phase-development | ⚠️ | ✅ | ⚠️ | ✅ | ⚠️ | ✅ |
| investigation-workflow | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ⚠️ |
| 安全性機能（破壊的コマンドブロック） | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 公開リポジトリ特化機能 | - | - | - | - | ✅ | - |

✅: 高優先度 / ⚠️: 中優先度 / -: 既存構成あり/非該当

---

## 🆘 トラブルシューティング

### よくある問題

#### 1. デプロイスクリプトが見つからない
```bash
# prompt-patternsの最新版を取得
cd /path/to/prompt-patterns
git pull origin main

# 実行権限を確認
chmod +x scripts/deploy.sh
```

#### 2. 既存ファイルが上書きされた
```bash
# バックアップから復元
cp .claude.backup-YYYYMMDD/hooks/custom-hook.sh .claude/hooks/
```

#### 3. check_uncommitted.sh が動作しない
```bash
# 実行権限を確認
chmod +x .claude/hooks/check_uncommitted.sh

# settings.json を確認
cat .claude/settings.json | jq .
```

---

## 📞 サポート

### ドキュメント
1. **包括的ガイド**: ../DEPLOYMENT_GUIDE.md
2. **リポジトリ別案内**: このディレクトリ内の NOTICE_FOR_*.md

### 問題報告
- GitHub Issues: https://github.com/Yaaasoh/prompt-patterns/issues

---

## ✅ チェックリスト

導入完了時の確認:

- [ ] 適切な案内ドキュメントを選択した
- [ ] バックアップを作成した
- [ ] デプロイを実行した
- [ ] Stop Hook の動作を確認した
- [ ] git commit & push を完了した

---

**作成日**: 2025-11-28
**対象バージョン**: prompt-patterns Phase 1-4統合版
