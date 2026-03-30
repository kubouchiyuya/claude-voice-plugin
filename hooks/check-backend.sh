#!/bin/bash
# MCP版がアクティブな場合はPlugin版のhookをスキップする
# 両方インストール時の二重通知を防止

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_FILE="$PLUGIN_DIR/scripts/.active-backend"

# .active-backendファイルで明示的に切り替え済みの場合
if [ -f "$BACKEND_FILE" ]; then
  ACTIVE=$(cat "$BACKEND_FILE" 2>/dev/null)
  if [ "$ACTIVE" = "mcp" ]; then
    # MCP版が選択されているのでPlugin版hookはスキップ
    exit 0
  fi
fi

# MCP版のnotify.shが存在し、かつ.claude.jsonにvoice-notifyのMCPサーバーが登録されている場合
MCP_NOTIFY="$HOME/Projects/claude-voice-notify/notify.sh"
CLAUDE_JSON="$HOME/.claude.json"

if [ -f "$MCP_NOTIFY" ] && [ -f "$CLAUDE_JSON" ]; then
  if grep -q '"voice-notify"' "$CLAUDE_JSON" 2>/dev/null; then
    # 明示的な選択がない場合、MCP版を優先（既存ユーザー保護）
    if [ ! -f "$BACKEND_FILE" ]; then
      exit 0
    fi
  fi
fi

# Plugin版で通知を実行
"$PLUGIN_DIR/scripts/notify.sh" "$@"
