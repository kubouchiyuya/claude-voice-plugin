---
description: "音声通知の管理 - テスト再生、ON/OFF切替、設定変更"
argument-hint: "[test|on|off|status|speak <message>]"
allowed-tools: [Bash, Read]
---

# /voice コマンド

音声通知の管理コマンド。引数に応じて以下を実行する。

## 引数の処理

NOTIFY パスは `${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh` を使用する。

### 引数なし or `test`
テスト再生を実行：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh "テスト再生です。音声通知が正常に動作しています" complete
```

### `on`
音声通知をONにする：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh on
```

### `off`
音声通知をOFFにする：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh off
```

### `status`
現在の設定を表示：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh status
```

### `speak <message>`
指定メッセージを読み上げ：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh "<message>"
```

### `settings`
対話式設定パネルを開く：
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/settings.sh
```

結果をユーザーに報告すること。
