# space-antenna.com インフラ管理 - 技術情報

**最終更新**: 2025年12月15日
**管理リポジトリ**: [space-antenna-infrastructure](https://github.com/Yaaasoh/space-antenna-infrastructure)

---

## 📊 サーバー構成

### 基本情報
- **サーバー**: Xserver (xs743063.xsrv.jp)
- **ポート**: 10022
- **ユーザー**: xs743063
- **プロバイダ**: Xserver (sv16490)

### 運用中の4プロジェクト

| プロジェクト | デプロイ先 | 技術スタック | SSH秘密鍵 | 公開URL |
|-------------|-----------|-------------|----------|---------|
| jsbsim-flightgear-guide | `/jsbsim-guide/` | Hugo | xs743063.key | https://space-antenna.com/jsbsim-guide/ |
| tech-articles | `/rockets-facilities/` | Quarto | xs743063.key | https://space-antenna.com/rockets-facilities/ |
| vibration-diagnosis-prototype | `/vibration-analysis-tool/` | HTML/JS/Pyodide | github_actions_xserver | https://space-antenna.com/vibration-analysis-tool/ |
| space-fund-curation | `/space-strategy-info/` | WordPress | API経由 | https://space-antenna.com/space-strategy-info/ |

---

## 🔑 SSH秘密鍵管理

### 管理中の秘密鍵（2種類）

**1. xs743063.key**
- 用途: jsbsim-guide、rockets-facilities
- マスター保管場所: `space-antenna-infrastructure/config/keys/xs743063.key`
- 従来保管場所: `jsbsim-flightgear-guide/config/server/xs743063.key`
- パーミッション: 600

**2. github_actions_xserver**
- 用途: vibration-analysis-tool
- 保管場所: `~/.ssh/github_actions_xserver`、`space-antenna-infrastructure/config/keys/`
- パーミッション: 600

### 秘密鍵のコピー手順

```bash
# space-antenna-infrastructureへコピー
cp /c/Users/xprin/github/jsbsim-flightgear-guide/config/server/xs743063.key \
   /c/Users/xprin/github/space-antenna-infrastructure/config/keys/

cp ~/.ssh/github_actions_xserver \
   /c/Users/xprin/github/space-antenna-infrastructure/config/keys/

# パーミッション設定
chmod 600 /c/Users/xprin/github/space-antenna-infrastructure/config/keys/*
```

---

## 🚀 デプロイ方法

### 統一デプロイスクリプト（推奨）

**space-antenna-infrastructureリポジトリから実行**:

```bash
# 全プロジェクト一括デプロイ
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-all.sh

# 個別デプロイ
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-jsbsim-guide.sh
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-rockets.sh
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-vibration.sh
```

### 各プロジェクトのビルド・デプロイ手順

**jsbsim-guide (Hugo)**:
```bash
cd /c/Users/xprin/github/jsbsim-flightgear-guide/hugo-site
hugo --cleanDestinationDir
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-jsbsim-guide.sh
```

**rockets-facilities (Quarto)**:
```bash
cd /c/Users/xprin/github/tech-articles
quarto render
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-rockets.sh
```

**vibration-analysis-tool (HTML/JS)**:
```bash
cd /c/Users/xprin/github/vibration-diagnosis-prototype/website/prototypes/pyodide-v2
# ビルドは不要（静的ファイル）
bash /c/Users/xprin/github/space-antenna-infrastructure/scripts/deploy-vibration.sh
```

---

## ⚠️ 重要な注意事項

### GitHub Actions自動デプロイについて

**現状**: 一時停止中

**理由**:
1. 一定時間以上の実行は有料
2. 過去にClaude Codeが致命的な実装ミスで不適切にワークフローを作動させクレジットを浪費
3. デプロイではない作業でワークフローを誤作動させた

**推奨**: 手動デプロイスクリプトを使用

**将来的な再開条件**:
- ワークフローの厳格なトリガー条件設定
- テスト環境での十分な検証
- コスト監視体制の確立

### 秘密鍵の取り扱い

**絶対に実施してはならないこと**:
- ❌ 秘密鍵をGitにコミット
- ❌ 秘密鍵をパブリックリポジトリに含める
- ❌ 秘密鍵のパーミッションを644以上に設定

**必須事項**:
- ✅ `.gitignore`で秘密鍵を除外
- ✅ パーミッション600に設定
- ✅ space-antenna-infrastructureリポジトリでのみ一元管理

---

## 📁 リポジトリ別の役割

### space-antenna-infrastructure（新設）
- **役割**: サーバー統合管理、SSH秘密鍵の一元管理、デプロイスクリプト
- **URL**: https://github.com/Yaaasoh/space-antenna-infrastructure
- **重要度**: ⭐⭐⭐（最重要）

### jsbsim-flightgear-guide
- **役割**: 暫定マスター管理リポジトリ（xs743063.keyのオリジナル保管場所）
- **デプロイ**: このリポジトリのClaude Codeセッションで実行
- **URL**: https://github.com/Yaaasoh/jsbsim-flightgear-guide

### tech-articles
- **役割**: Quarto記事公開
- **秘密鍵**: jsbsim-flightgear-guideからコピー
- **URL**: https://github.com/Yaaasoh/tech-articles

### vibration-diagnosis-prototype
- **役割**: Pyodide Webアプリ公開
- **秘密鍵**: 別の秘密鍵（github_actions_xserver）を使用
- **注意**: バージョン選択ページ（`/vibration-analysis-tool/`）がメインURL
- **URL**: https://github.com/Yaaasoh/vibration-diagnosis-prototype

### space-fund-curation
- **役割**: WordPressサイト
- **デプロイ**: WordPress REST API経由（SSH秘密鍵不使用）
- **URL**: https://github.com/Yaaasoh/space-fund-curation

---

## 🎯 今後の改善計画

### Phase 1: 基本統合（実施中）
- ✅ space-antenna-infrastructureリポジトリ作成
- ✅ デプロイスクリプト作成
- ⏳ SSH秘密鍵の一元化（コピー作業実施中）
- ⏳ 各プロジェクトのREADME更新

### Phase 2: 自動化（慎重に検討）
- ⏳ GitHub Actions再設計（コスト最適化）
- ⏳ デプロイ通知機能
- ⏳ サーバーヘルスチェック

### Phase 3: 高度化（将来）
- ⏳ Terraformによるインフラコード化
- ⏳ 監視・アラート体制
- ⏳ バックアップ自動化

---

## 📚 参考ドキュメント

- **space-antenna-infrastructure/README.md**: サーバー全体構成
- **jsbsim-flightgear-guide/config/server/SERVER_CONFIG.md**: SSH接続詳細
- **tech-articles/config/server/README.md**: サーバー管理体制
- **各リポジトリのCLAUDE.md**: Claude Code使用方法

---

**作成者**: Claude Code (Sonnet 4.5)
**用途**: Claude ProjectsおよびClaude Code CLIでの技術参照
