# Claude Voice Plugin

Claude Code 用 VOICEVOX 音声通知プラグイン。MCP サーバー不要でコンテキスト消費ゼロの自動音声通知を実現。

## MCP版との違い

| | MCP版 | Plugin版（本リポジトリ） |
|---|---|---|
| 常時コンテキストコスト | ~600-950 tok | **0 tok** |
| カスタム音声使用時 | +200 tok | +200 tok（Bash経由） |
| 自動通知 | MCP tool呼出 | Hooks（コンテキスト0） |
| 機能 | 5ツール | **全機能維持** |

## 前提条件

- [VOICEVOX](https://voicevox.hiroshiba.jp/) が `http://localhost:50021` で起動していること
- macOS（`afplay` コマンドを使用）
- Python 3（URL エンコード・JSON パースに使用）

## インストール

### 方法1: プラグインディレクトリに配置

```bash
git clone https://github.com/kubouchiyuya/claude-voice-plugin.git \
  ~/.claude/plugins/voice-notify
```

### 方法2: シンボリックリンク

```bash
git clone https://github.com/kubouchiyuya/claude-voice-plugin.git \
  ~/Projects/claude-voice-plugin

ln -s ~/Projects/claude-voice-plugin ~/.claude/plugins/voice-notify
```

### プラグインを有効化

Claude Code の設定（`~/.claude/settings.json`）に追加：

```json
{
  "enabledPlugins": {
    "voice-notify": true
  }
}
```

## 構造

```
claude-voice-plugin/
├── .claude-plugin/
│   └── plugin.json          # プラグインメタデータ
├── hooks/
│   └── hooks.json           # 自動通知フック（Notification, Stop）
├── skills/
│   └── voice-notify/
│       └── SKILL.md         # カスタム音声スキル定義
├── commands/
│   └── voice.md             # /voice スラッシュコマンド
└── scripts/
    ├── notify.sh            # 音声通知 CLI
    └── settings.sh          # 対話式設定パネル
```

## 使い方

### 自動通知（Hooks - コンテキスト0）

プラグインを有効にするだけで、以下が自動で音声通知されます：

- **Notification イベント** → 「確認をお願いします」
- **Stop イベント** → 「タスクが完了しました」

### カスタム音声（Skill - オンデマンド）

Claude に話しかけるだけで、Skill が自動でロードされます：

- 「音声でテストして」
- 「この変更内容を声で説明して」
- 「音声オフにして」

### /voice コマンド

```
/voice test      # テスト再生
/voice on        # 音声ON
/voice off       # 音声OFF
/voice status    # 設定確認
/voice settings  # 設定パネル
```

### CLI 直接使用

```bash
# 読み上げ
./scripts/notify.sh "メッセージ"
./scripts/notify.sh "メッセージ" complete 3 1.2

# 設定
./scripts/notify.sh set-speaker 8
./scripts/notify.sh set-speed 1.2
./scripts/notify.sh set-volume 0.5
./scripts/notify.sh list

# ON/OFF
./scripts/notify.sh on / off / status
```

## 設定

設定は `scripts/.voice-config` に保存されます：

```bash
DEFAULT_SPEAKER=3        # VOICEVOXスピーカーID
DEFAULT_SPEED=1.5        # 読み上げ速度（0.5〜2.0）
DEFAULT_VOLUME=0.3       # 音量（0.0〜1.0）
DEFAULT_PROVIDER=voicevox  # TTS プロバイダー
```

## 対応プロバイダー

- **VOICEVOX** (デフォルト) - 無料・ローカル実行
- **Google Cloud TTS** - 高品質・API キー必要

## ライセンス

MIT

## 音声合成ソフトウェアの利用について

VOICEVOX のキャラクターボイスは各キャラクターの利用規約に従ってください。
商用利用時は各キャラクターの利用規約を確認してください。
