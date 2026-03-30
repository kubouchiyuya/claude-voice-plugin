---
name: voice-notify
description: "This skill should be used when the user asks to 'read aloud', 'speak', 'voice notification', 'notify', '音声通知', '読み上げ', '声で教えて', 'テスト再生', 'voice test', 'set speaker', 'set volume', 'キャラ変更', '音量', '速度', 'voice off', 'voice on', '静かにして', '音声オフ', '音声オン', when Claude needs to notify the user about task completion, confirmations, errors, or any situation requiring audio feedback."
version: 2.0.0
---

# Voice Box 音声通知スキル

VOICEVOX/Google Cloud TTS を使った音声通知。notify.sh CLI を Bash で呼び出して全機能を実行する。

## CLI パス

```
NOTIFY="${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh"
```

## 基本コマンド

### 読み上げ
```bash
$NOTIFY "メッセージ"                          # デフォルトキャラで読み上げ
$NOTIFY "メッセージ" complete                  # 完了通知
$NOTIFY "メッセージ" confirm                   # 確認通知
$NOTIFY "メッセージ" error                     # エラー通知
$NOTIFY "メッセージ" complete 3 1.2            # タイプ/スピーカーID/速度を指定
```

### 設定変更
```bash
$NOTIFY set-speaker 8                         # デフォルトキャラ変更
$NOTIFY set-speed 1.2                         # デフォルト速度変更（0.5〜2.0）
$NOTIFY set-volume 0.5                        # デフォルト音量変更（0.0〜1.0）
$NOTIFY set-provider voicevox                 # プロバイダー変更
$NOTIFY set-provider google                   # Google Cloud TTS
$NOTIFY set-google-key <API_KEY>              # Google APIキー設定
```

### 管理
```bash
$NOTIFY on                                    # 音声ON
$NOTIFY off                                   # 音声OFF
$NOTIFY status                                # 現在の設定表示
$NOTIFY list                                  # VOICEVOXキャラクター一覧
```

### 設定パネル（対話式UI）
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/settings.sh     # キャラ・速度・音量・方言・エンジン
```

## 必ず音声で通知する場面（スキップ不可）

音声通知がONである限り、以下の場面では**必ず** notify.sh を呼ぶ：

1. **タスク開始時** — 作業前に「これから何をするか」を宣言
2. **作業が止まる時** — ユーザーの入力・判断待ちで開発が停止する全場面
3. **承認・許可を求める時** — ファイル削除、デプロイ、破壊的変更の前
4. **選択肢を提示する時** — 複数のアプローチからユーザーに選んでもらう時
5. **タスク完了時** — 一連の作業が終わった時（必ず完了報告）
6. **エラー発生時** — ビルドエラー、実行エラー、接続エラー等

## 音声メッセージのルール

- **具体的に**何をしたか説明する（「タスクが完了しました」は禁止）
- 長いメッセージは40文字程度で分割して複数回呼ぶ
- 読み上げテキストは**話し言葉**にする
- 技術用語はかみ砕いて説明する

### 良い例
```bash
$NOTIFY "了解しました。ログイン機能を実装します"
$NOTIFY "ログイン機能の実装が完了しました。JWT認証を使っています"
$NOTIFY "確認です。データベースのテーブルを削除してよいですか？" confirm
$NOTIFY "ビルドエラーです。型エラーが3件あります" error
```

### 悪い例（禁止）
```bash
$NOTIFY "タスクが完了しました"          # 汎用メッセージ禁止
$NOTIFY "確認をお願いします"            # 何の確認か不明
```

## 音声のオン/オフ制御

ユーザーが「静かにして」「音声オフ」「ミュート」と言ったら：
```bash
$NOTIFY off
```

「音声オン」「音出して」と言ったら：
```bash
$NOTIFY on
```
